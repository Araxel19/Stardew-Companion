import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../models/save_data.dart';

class ModScannerService {
  static Future<List<StardewModInfo>> scanMods({String? customPath}) async {
    final List<StardewModInfo> mods = [];
    final Set<String> processedPaths = {};

    final List<String> searchPaths = [];

    if (customPath != null && customPath.isNotEmpty) {
      searchPaths.add(customPath);
    }

    if (Platform.isWindows) {
      // Rutas conocidas en Windows
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      final appData = Platform.environment['APPDATA'] ?? '';

      if (userProfile.isNotEmpty) {
        searchPaths.add(p.join(userProfile, 'Documents', 'ModsStardewV'));
        searchPaths.add(p.join(userProfile, 'Documents', 'StardewValley', 'Mods'));
      }
      if (appData.isNotEmpty) {
        searchPaths.add(p.join(appData, 'StardewValley', 'Mods'));
      }

      searchPaths.addAll([
        r'C:\Program Files (x86)\Steam\steamapps\common\Stardew Valley\Mods',
        r'C:\Program Files\Steam\steamapps\common\Stardew Valley\Mods',
        r'C:\Games\Stardew Valley\Mods',
        r'D:\Games\Stardew Valley\Mods',
        r'D:\SteamLibrary\steamapps\common\Stardew Valley\Mods',
      ]);
    } else if (Platform.isAndroid) {
      // Rutas conocidas en Android (SMAPI Android y carpetas estándar)
      searchPaths.addAll([
        '/storage/emulated/0/StardewValley/Mods',
        '/storage/emulated/0/Android/data/com.zane.smapi/files/Mods',
        '/sdcard/StardewValley/Mods',
      ]);
    }

    for (final path in searchPaths) {
      try {
        final dir = Directory(path);
        if (await dir.exists()) {
          await _scanDirectory(dir, mods, processedPaths);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al escanear directorio de mods en $path: $e');
        }
      }
    }

    return mods;
  }

  static Future<void> _scanDirectory(
    Directory dir,
    List<StardewModInfo> mods,
    Set<String> processedPaths,
  ) async {
    try {
      final entities = await dir.list(recursive: true, followLinks: false).toList();

      for (final entity in entities) {
        if (entity is File && p.basename(entity.path).toLowerCase() == 'manifest.json') {
          final parentPath = entity.parent.path;
          if (processedPaths.contains(parentPath)) continue;
          processedPaths.add(parentPath);

          try {
            final content = await entity.readAsString();
            final Map<String, dynamic> json = jsonDecode(content);

            final name = json['Name']?.toString() ?? p.basename(parentPath);
            final version = json['Version']?.toString() ?? '1.0.0';
            final author = json['Author']?.toString() ?? 'Desconocido';
            final description = json['Description']?.toString() ?? '';
            final uniqueId = json['UniqueId']?.toString() ?? name;

            mods.add(StardewModInfo(
              name: name,
              version: version,
              author: author,
              description: description,
              uniqueId: uniqueId,
              folderPath: parentPath,
            ));
          } catch (_) {
            // Si el JSON falla, incluir la carpeta como mod fallback
            mods.add(StardewModInfo(
              name: p.basename(parentPath),
              version: 'Desconocida',
              author: 'Desconocido',
              description: '',
              uniqueId: p.basename(parentPath),
              folderPath: parentPath,
            ));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leyendo contenido de ${dir.path}: $e');
      }
    }
  }
}
