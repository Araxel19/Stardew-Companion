import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/save_data.dart';
import '../services/mod_scanner_service.dart';

/// Provider de mods instalados de Stardew Valley.
///
/// Soporta activación/desactivación de mods de forma aislada por partida (granja).
class ModProvider extends ChangeNotifier {
  List<StardewModInfo> _installedMods = [];
  String? _customModsFolderPath;
  final Map<String, bool> _farmModsEnabledMap = {};

  List<StardewModInfo> get installedMods => List.unmodifiable(_installedMods);
  String? get customModsFolderPath => _customModsFolderPath;

  ModProvider() {
    scanInstalledMods(shouldNotify: false);
  }

  Future<void> scanInstalledMods({
    String? customPath,
    bool shouldNotify = true,
  }) async {
    if (customPath != null) {
      _customModsFolderPath = customPath;
    }
    _installedMods = await ModScannerService.scanMods(
      customPath: _customModsFolderPath,
    );
    if (shouldNotify) notifyListeners();
  }

  /// Indica si los mods están habilitados para una granja en particular.
  bool isModsEnabledForFarm(String farmKey) {
    return _farmModsEnabledMap[farmKey] ?? true;
  }

  /// Carga el estado de preferencia de mods para una granja.
  Future<void> loadModsForFarm(String farmKey) async {
    final setting = await DBHelper.getSetting('mods_enabled_$farmKey');
    if (setting != null) {
      _farmModsEnabledMap[farmKey] = setting == '1';
    } else {
      _farmModsEnabledMap[farmKey] = true;
    }
    notifyListeners();
  }

  /// Alterna los mods para una granja y guarda la preferencia.
  Future<void> toggleModsForFarm(String farmKey, bool enabled) async {
    _farmModsEnabledMap[farmKey] = enabled;
    await DBHelper.saveSetting('mods_enabled_$farmKey', enabled ? '1' : '0');
    notifyListeners();
  }
}
