import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/crop_model.dart';
import '../models/default_stardew_data.dart';
import '../models/save_data.dart';
import '../services/backup_service.dart';
import '../services/xml_parser_service.dart';
import '../theme/stardew_theme.dart';

class AppStateProvider extends ChangeNotifier {
  StardewSaveData? _activeSaveData;
  List<Map<String, dynamic>> _savedFarms = [];
  List<CropModel> _allCrops = [];
  List<Map<String, dynamic>> _ledgerEntries = [];
  List<Map<String, dynamic>> _tasks = [];
  
  bool _isLoadingSave = false;
  String? _saveErrorMessage;
  String _selectedSeason = 'Primavera';

  // Opciones de Configuración
  String _locale = 'es'; // 'es' or 'en'
  StardewThemeMode _themeMode = StardewThemeMode.iridium;

  // Getters
  StardewSaveData? get activeSaveData => _activeSaveData;
  List<Map<String, dynamic>> get savedFarms => _savedFarms;
  List<CropModel> get allCrops => _allCrops;
  List<Map<String, dynamic>> get ledgerEntries => _ledgerEntries;
  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoadingSave => _isLoadingSave;
  String? get saveErrorMessage => _saveErrorMessage;
  String get selectedSeason => _selectedSeason;

  String get locale => _locale;
  StardewThemeMode get themeMode => _themeMode;

  AppStateProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _allCrops = List.from(DefaultStardewData.defaultCrops);
    await refreshFarms();
    await refreshLedger();
    await refreshTasks();
    await _loadCustomCrops();
    
    // Cargar la última partida conocida o por defecto
    if (_savedFarms.isNotEmpty) {
      final lastPath = _savedFarms.first['savePath'];
      await loadSaveFile(lastPath);
    } else {
      const defaultSavePath = r'C:\Users\Araxel\AppData\Roaming\StardewValley\Saves\NegroLand_420848748\NegroLand_420848748';
      await loadSaveFile(defaultSavePath);
    }
  }

  void setLocale(String newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  void setThemeMode(StardewThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSelectedSeason(String season) {
    _selectedSeason = season;
    notifyListeners();
  }

  // --- Múltiples Partidas / Granjas ---
  Future<void> refreshFarms() async {
    _savedFarms = await DBHelper.getSavedFarms();
    notifyListeners();
  }

  Future<void> loadSaveFile(String filePath) async {
    _isLoadingSave = true;
    _saveErrorMessage = null;
    notifyListeners();

    try {
      final saveData = await XmlParserService.parseSaveFile(filePath);
      _activeSaveData = saveData;
      _isLoadingSave = false;

      // Registrar partida en SQLite para cambio rápido
      await DBHelper.saveFarmRecord(
        farmerName: saveData.farmerName,
        farmName: saveData.farmName,
        gold: saveData.currentMoney,
        savePath: filePath,
      );
      await refreshFarms();
      notifyListeners();
    } catch (e) {
      _saveErrorMessage = e.toString();
      _isLoadingSave = false;
      notifyListeners();
    }
  }

  // --- Respaldos JSON ---
  Future<String?> exportDataBackup() async {
    return await BackupService.exportBackup();
  }

  Future<bool> importDataBackup(String filePath) async {
    final success = await BackupService.importBackup(filePath);
    if (success) {
      await refreshFarms();
      await refreshLedger();
      await refreshTasks();
      await _loadCustomCrops();
      notifyListeners();
    }
    return success;
  }

  // --- SQLite Financial Ledger Operations ---
  Future<void> refreshLedger() async {
    _ledgerEntries = await DBHelper.getLedgerEntries();
    notifyListeners();
  }

  Future<void> addLedgerEntry({
    required String title,
    required String type,
    required String category,
    required double amount,
    required String date,
    String? notes,
  }) async {
    await DBHelper.insertLedger({
      'title': title,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes ?? '',
    });
    await refreshLedger();
  }

  Future<void> deleteLedgerEntry(int id) async {
    await DBHelper.deleteLedgerEntry(id);
    await refreshLedger();
  }

  // --- SQLite Tasks Operations ---
  Future<void> refreshTasks() async {
    _tasks = await DBHelper.getTasks();
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String season,
    required int day,
    String category = 'General',
  }) async {
    await DBHelper.insertTask({
      'title': title,
      'season': season,
      'day': day,
      'year': 1,
      'isCompleted': 0,
      'category': category,
    });
    await refreshTasks();
  }

  Future<void> toggleTask(int id, bool currentStatus) async {
    await DBHelper.updateTaskStatus(id, !currentStatus);
    await refreshTasks();
  }

  Future<void> deleteTask(int id) async {
    await DBHelper.deleteTask(id);
    await refreshTasks();
  }

  // --- Custom Mod Crops ---
  Future<void> _loadCustomCrops() async {
    final customCropsList = await DBHelper.getCustomCrops();
    for (var map in customCropsList) {
      _allCrops.add(CropModel(
        id: 'custom_${map['id']}',
        name: map['name'],
        season: map['season'],
        seedCost: (map['seedCost'] as num).toDouble(),
        baseSellPrice: (map['sellPrice'] as num).toDouble(),
        daysToGrow: map['daysToGrow'] as int,
        regrowDays: map['regrowDays'] as int,
        sourceMod: map['sourceMod'] ?? 'Custom Mod',
      ));
    }
    notifyListeners();
  }

  Future<void> addCustomCrop({
    required String name,
    required String season,
    required double seedCost,
    required double sellPrice,
    required int daysToGrow,
    int regrowDays = 0,
    required String sourceMod,
  }) async {
    await DBHelper.insertCustomCrop({
      'name': name,
      'season': season,
      'seedCost': seedCost,
      'sellPrice': sellPrice,
      'daysToGrow': daysToGrow,
      'regrowDays': regrowDays,
      'sourceMod': sourceMod,
    });
    
    _allCrops.add(CropModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      season: season,
      seedCost: seedCost,
      baseSellPrice: sellPrice,
      daysToGrow: daysToGrow,
      regrowDays: regrowDays,
      sourceMod: sourceMod,
    ));
    notifyListeners();
  }
}
