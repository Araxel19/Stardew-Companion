import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/db_helper.dart';

class BackupService {
  // Exportar base de datos a JSON
  static Future<String?> exportBackup() async {
    final ledger = await DBHelper.getLedgerEntries();
    final tasks = await DBHelper.getTasks();
    final customCrops = await DBHelper.getCustomCrops();
    final farms = await DBHelper.getSavedFarms();

    final dataMap = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'ledger': ledger,
      'tasks': tasks,
      'customCrops': customCrops,
      'farms': farms,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(dataMap);

    final docsDir = await getApplicationDocumentsDirectory();
    final filePath = '${docsDir.path}/stardew_companion_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  // Importar desde archivo JSON
  static Future<bool> importBackup(String jsonFilePath) async {
    final file = File(jsonFilePath);
    if (!await file.exists()) return false;

    final jsonString = await file.readAsString();
    final Map<String, dynamic> dataMap = jsonDecode(jsonString);

    if (dataMap.containsKey('ledger')) {
      final List ledgerList = dataMap['ledger'];
      for (var item in ledgerList) {
        await DBHelper.insertLedger(Map<String, dynamic>.from(item));
      }
    }

    if (dataMap.containsKey('tasks')) {
      final List tasksList = dataMap['tasks'];
      for (var item in tasksList) {
        await DBHelper.insertTask(Map<String, dynamic>.from(item));
      }
    }

    if (dataMap.containsKey('customCrops')) {
      final List cropsList = dataMap['customCrops'];
      for (var item in cropsList) {
        await DBHelper.insertCustomCrop(Map<String, dynamic>.from(item));
      }
    }

    return true;
  }
}
