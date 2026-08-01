import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class SaveScannerService {
  static Future<List<Map<String, dynamic>>> scanLocalSaves() async {
    final List<Map<String, dynamic>> saves = [];
    final Set<String> searchDirectories = {};

    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      if (appData.isNotEmpty) {
        searchDirectories.add(p.canonicalize(p.join(appData, 'StardewValley', 'Saves')));
      }
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      if (userProfile.isNotEmpty) {
        searchDirectories.add(p.canonicalize(p.join(userProfile, 'AppData', 'Roaming', 'StardewValley', 'Saves')));
      }
    } else if (Platform.isAndroid) {
      searchDirectories.addAll([
        '/storage/emulated/0/StardewValley',
        '/storage/emulated/0/Android/data/com.chucklefish.stardewvalley/files/Saves',
        '/sdcard/StardewValley',
      ]);
    }

    final Set<String> processedKeys = {};

    for (final dirPath in searchDirectories) {
      try {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final entities = await dir.list(recursive: false).toList();
          for (final entity in entities) {
            if (entity is Directory) {
              final folderName = p.basename(entity.path);
              final saveFilePath = p.join(entity.path, folderName);
              final saveFile = File(saveFilePath);
              
              String? targetPath;
              if (await saveFile.exists()) {
                targetPath = saveFile.path;
              } else {
                final subFiles = await entity.list().toList();
                for (final subFile in subFiles) {
                  if (subFile is File && !p.basename(subFile.path).startsWith('SaveGameInfo')) {
                    targetPath = subFile.path;
                    break;
                  }
                }
              }

              if (targetPath != null) {
                final canonicalPath = p.canonicalize(targetPath);
                final saveInfo = await _extractBasicSaveInfo(canonicalPath);
                if (saveInfo != null) {
                  final key = '${saveInfo['farmerName']}_${saveInfo['farmName']}'.toLowerCase();
                  if (!processedKeys.contains(key) && !processedKeys.contains(canonicalPath.toLowerCase())) {
                    processedKeys.add(key);
                    processedKeys.add(canonicalPath.toLowerCase());
                    saves.add(saveInfo);
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error escaneando carpeta de guardado $dirPath: $e');
        }
      }
    }

    return saves;
  }

  static Future<Map<String, dynamic>?> _extractBasicSaveInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final document = XmlDocument.parse(content);

      final farmerNode = document.findAllElements('Farmer').firstOrNull ??
          document.findAllElements('player').firstOrNull ??
          document.rootElement;

      final name = farmerNode.findElements('name').firstOrNull?.innerText ?? p.basename(filePath).split('_').first;
      final farmName = farmerNode.findElements('farmName').firstOrNull?.innerText ?? 'Granja';
      final money = int.tryParse(farmerNode.findElements('money').firstOrNull?.innerText ?? '0') ?? 0;

      return {
        'farmerName': name,
        'farmName': farmName,
        'gold': money,
        'savePath': filePath,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (_) {
      return null;
    }
  }
}
