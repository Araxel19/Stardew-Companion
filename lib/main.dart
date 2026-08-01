import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/app_state_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/ledger_provider.dart';
import 'providers/mod_provider.dart';
import 'providers/planted_crop_provider.dart';
import 'providers/save_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'theme/stardew_theme.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const StardewCompanionApp());
}

class StardewCompanionApp extends StatelessWidget {
  const StardewCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancias de providers especializados (independientes entre sí)
    final settingsProvider = SettingsProvider();
    final saveProvider = SaveProvider();
    final cropProvider = CropProvider();
    final ledgerProvider = LedgerProvider();
    final taskProvider = TaskProvider();
    final modProvider = ModProvider();
    final plantedCropProvider = PlantedCropProvider();

    return MultiProvider(
      providers: [
        // Providers especializados — cada uno gestiona su propio dominio
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<SaveProvider>.value(value: saveProvider),
        ChangeNotifierProvider<CropProvider>.value(value: cropProvider),
        ChangeNotifierProvider<LedgerProvider>.value(value: ledgerProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ChangeNotifierProvider<ModProvider>.value(value: modProvider),
        ChangeNotifierProvider<PlantedCropProvider>.value(value: plantedCropProvider),

        // Fachada de compatibilidad — agrega el AppStateProvider que delega
        // en los providers especializados para que las vistas no rompan.
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(
            saveProvider: saveProvider,
            cropProvider: cropProvider,
            ledgerProvider: ledgerProvider,
            taskProvider: taskProvider,
            modProvider: modProvider,
            settingsProvider: settingsProvider,
            plantedCropProvider: plantedCropProvider,
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Stardew Companion',
            debugShowCheckedModeBanner: false,
            theme: StardewTheme.getTheme(settings.themeMode),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
