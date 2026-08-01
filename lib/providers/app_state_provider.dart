import 'package:flutter/foundation.dart';
import '../models/crop_model.dart';
import '../models/save_data.dart';
import '../theme/stardew_theme.dart';
import 'crop_provider.dart';
import 'ledger_provider.dart';
import 'mod_provider.dart';
import 'save_provider.dart';
import 'settings_provider.dart';
import 'task_provider.dart';

/// Provider de compatibilidad — fachada sobre los providers especializados.
///
/// Permite que las vistas existentes sigan usando [AppStateProvider]
/// durante la migración a providers especializados.
///
/// MIGRACIÓN: Cada vista debería progresivamente cambiar a usar directamente
/// [SaveProvider], [CropProvider], [LedgerProvider], [TaskProvider],
/// [ModProvider] o [SettingsProvider] según corresponda.
///
/// Cuando todas las vistas estén migradas, este archivo puede eliminarse.
import 'planted_crop_provider.dart';

class AppStateProvider extends ChangeNotifier {
  final SaveProvider _saveProvider;
  final CropProvider _cropProvider;
  final LedgerProvider _ledgerProvider;
  final TaskProvider _taskProvider;
  final ModProvider _modProvider;
  final SettingsProvider _settingsProvider;
  final PlantedCropProvider _plantedCropProvider;
  String _lastSyncedFarmKey = '';

  AppStateProvider({
    required SaveProvider saveProvider,
    required CropProvider cropProvider,
    required LedgerProvider ledgerProvider,
    required TaskProvider taskProvider,
    required ModProvider modProvider,
    required SettingsProvider settingsProvider,
    required PlantedCropProvider plantedCropProvider,
  })  : _saveProvider = saveProvider,
        _cropProvider = cropProvider,
        _ledgerProvider = ledgerProvider,
        _taskProvider = taskProvider,
        _modProvider = modProvider,
        _settingsProvider = settingsProvider,
        _plantedCropProvider = plantedCropProvider {
    _saveProvider.addListener(_onSaveChanged);
    _cropProvider.addListener(_relay);
    _ledgerProvider.addListener(_relay);
    _taskProvider.addListener(_relay);
    _modProvider.addListener(_relay);
    _settingsProvider.addListener(_relay);
    _plantedCropProvider.addListener(_relay);
  }

  void _onSaveChanged() {
    final currentKey = _saveProvider.activeFarmKey;
    if (currentKey != _lastSyncedFarmKey) {
      _lastSyncedFarmKey = currentKey;
      _taskProvider.setFarmKey(currentKey);
      _plantedCropProvider.setFarmKey(currentKey);
      _ledgerProvider.setFarmKey(currentKey);
    }
    notifyListeners();
  }

  void _relay() => notifyListeners();

  @override
  void dispose() {
    _saveProvider.removeListener(_relay);
    _cropProvider.removeListener(_relay);
    _ledgerProvider.removeListener(_relay);
    _taskProvider.removeListener(_relay);
    _modProvider.removeListener(_relay);
    _settingsProvider.removeListener(_relay);
    super.dispose();
  }

  // ─── Getters de compatibilidad (delegación) ───────────────

  // SaveProvider
  StardewSaveData? get activeSaveData => _saveProvider.activeSaveData;
  List<Map<String, dynamic>> get savedFarms => _saveProvider.savedFarms;
  bool get isLoadingSave => _saveProvider.isLoadingSave;
  String? get saveErrorMessage => _saveProvider.saveErrorMessage;

  // CropProvider
  List<CropModel> get allCrops => _cropProvider.allCrops;

  // LedgerProvider
  List<Map<String, dynamic>> get ledgerEntries => _ledgerProvider.ledgerEntries;

  // TaskProvider
  List<Map<String, dynamic>> get tasks => _taskProvider.tasks;

  // ModProvider
  List<StardewModInfo> get installedMods => _modProvider.installedMods;
  String? get customModsFolderPath => _modProvider.customModsFolderPath;

  // SettingsProvider
  String get locale => _settingsProvider.locale;
  StardewThemeMode get themeMode => _settingsProvider.themeMode;
  String get appVersion => _settingsProvider.appVersion;

  // ─── Métodos de compatibilidad (delegación) ──────────────

  Future<void> scanAndLoadSaves() => _saveProvider.scanAndLoadSaves();
  Future<void> loadSaveFile(String filePath, {bool forceReload = false}) =>
      _saveProvider.loadSaveFile(filePath, forceReload: forceReload);
  Future<void> refreshFarms({bool shouldNotify = true}) =>
      _saveProvider.refreshFarms(shouldNotify: shouldNotify);
  Future<String?> exportDataBackup() => _saveProvider.exportDataBackup();
  Future<bool> importDataBackup(String filePath) =>
      _saveProvider.importDataBackup(filePath);

  Future<void> addCustomCrop({
    required String name,
    required String season,
    required double seedCost,
    required double sellPrice,
    required int daysToGrow,
    int regrowDays = 0,
    required String sourceMod,
  }) => _cropProvider.addCustomCrop(
        name: name, season: season, seedCost: seedCost, sellPrice: sellPrice,
        daysToGrow: daysToGrow, regrowDays: regrowDays, sourceMod: sourceMod,
      );

  Future<void> refreshLedger({bool shouldNotify = true}) =>
      _ledgerProvider.refreshLedger(shouldNotify: shouldNotify);
  Future<void> addLedgerEntry({
    required String title,
    required String type,
    required String category,
    required double amount,
    required String date,
    String? notes,
  }) => _ledgerProvider.addLedgerEntry(
        title: title, type: type, category: category,
        amount: amount, date: date, notes: notes,
      );
  Future<void> deleteLedgerEntry(int id) =>
      _ledgerProvider.deleteLedgerEntry(id);

  Future<void> refreshTasks({bool shouldNotify = true}) =>
      _taskProvider.refreshTasks(shouldNotify: shouldNotify);
  Future<void> addTask({
    required String title,
    required String season,
    required int day,
    String category = 'General',
  }) => _taskProvider.addTask(
        title: title, season: season, day: day, category: category,
      );
  Future<void> toggleTask(int id, bool currentStatus) =>
      _taskProvider.toggleTask(id, currentStatus);
  Future<void> deleteTask(int id) => _taskProvider.deleteTask(id);

  Future<void> scanInstalledMods({String? customPath, bool shouldNotify = true}) =>
      _modProvider.scanInstalledMods(
          customPath: customPath, shouldNotify: shouldNotify);

  void setLocale(String newLocale) => _settingsProvider.setLocale(newLocale);
  void setThemeMode(StardewThemeMode mode) =>
      _settingsProvider.setThemeMode(mode);
}
