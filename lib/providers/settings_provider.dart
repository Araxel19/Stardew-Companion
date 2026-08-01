import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/stardew_theme.dart';

/// Provider de configuración de la aplicación.
///
/// Gestiona: locale, modo de tema, versión de la app.
/// Extraído de [AppStateProvider] para cumplir el principio de responsabilidad única.
class SettingsProvider extends ChangeNotifier {
  String _locale = 'es';
  StardewThemeMode _themeMode = StardewThemeMode.iridium;
  String _appVersion = '0.3.1';

  String get locale => _locale;
  StardewThemeMode get themeMode => _themeMode;
  String get appVersion => _appVersion;

  SettingsProvider() {
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      notifyListeners();
    } catch (_) {}
  }

  void setLocale(String newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  void setThemeMode(StardewThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
