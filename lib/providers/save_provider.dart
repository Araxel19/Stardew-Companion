import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/save_data.dart';
import '../services/backup_service.dart';
import '../services/save_scanner_service.dart';
import '../services/xml_parser_service.dart';

/// Provider de partidas guardadas del granjero.
///
/// Gestiona: carga de archivos XML, escáner de partidas locales,
/// caché en memoria, y respaldo (backup). 
/// Extraído de [AppStateProvider].
class SaveProvider extends ChangeNotifier {
  StardewSaveData? _activeSaveData;
  List<Map<String, dynamic>> _savedFarms = [];
  final Map<String, StardewSaveData> _saveCache = {};
  bool _isLoadingSave = false;
  String? _saveErrorMessage;

  StardewSaveData? get activeSaveData => _activeSaveData;
  List<Map<String, dynamic>> get savedFarms => _savedFarms;
  bool get isLoadingSave => _isLoadingSave;
  String? get saveErrorMessage => _saveErrorMessage;

  String get activeFarmKey {
    if (_activeSaveData != null) {
      return '${_activeSaveData!.farmerName}_${_activeSaveData!.farmName}'.toLowerCase();
    }
    return 'global';
  }

  SaveProvider() {
    _init();
  }

  Future<void> _init() async {
    await scanAndLoadSaves();
  }

  Future<void> scanAndLoadSaves() async {
    final scanned = await SaveScannerService.scanLocalSaves();
    for (final farm in scanned) {
      await DBHelper.saveFarmRecord(
        farmerName: farm['farmerName'],
        farmName: farm['farmName'],
        gold: farm['gold'],
        savePath: farm['savePath'],
      );
    }
    await refreshFarms(shouldNotify: false);

    if (_activeSaveData == null && _savedFarms.isNotEmpty) {
      final lastPath = await DBHelper.getSetting('last_active_save_path');
      final targetPath = (lastPath != null && _savedFarms.any((f) => f['savePath'] == lastPath))
          ? lastPath
          : _savedFarms.first['savePath'];
      await loadSaveFile(targetPath);
    } else {
      notifyListeners();
    }
  }

  Future<void> refreshFarms({bool shouldNotify = true}) async {
    final rawFarms = await DBHelper.getSavedFarms();
    final unique = <String, Map<String, dynamic>>{};
    for (final farm in rawFarms) {
      final key =
          '${farm['farmerName']}_${farm['farmName']}'.toLowerCase();
      if (!unique.containsKey(key)) {
        unique[key] = farm;
      }
    }
    _savedFarms = unique.values.toList();
    if (shouldNotify) notifyListeners();
  }

  Future<void> loadSaveFile(String filePath, {bool forceReload = false}) async {
    _isLoadingSave = true;
    _saveErrorMessage = null;
    notifyListeners();

    try {
      StardewSaveData saveData;
      if (!forceReload && _saveCache.containsKey(filePath)) {
        saveData = _saveCache[filePath]!;
      } else {
        saveData = await compute(XmlParserService.parseSaveFile, filePath);
        _saveCache[filePath] = saveData;
      }

      _activeSaveData = saveData;
      _isLoadingSave = false;

      await DBHelper.saveFarmRecord(
        farmerName: saveData.farmerName,
        farmName: saveData.farmName,
        gold: saveData.currentMoney,
        savePath: filePath,
      );
      await DBHelper.saveSetting('last_active_save_path', filePath);
      await refreshFarms(shouldNotify: false);
      notifyListeners();
    } catch (e) {
      _saveErrorMessage = e.toString();
      _isLoadingSave = false;
      notifyListeners();
    }
  }

  Future<String?> exportDataBackup() async {
    return BackupService.exportBackup();
  }

  Future<bool> importDataBackup(String filePath) async {
    final success = await BackupService.importBackup(filePath);
    if (success) {
      _saveCache.clear();
      await refreshFarms();
    }
    return success;
  }
}
