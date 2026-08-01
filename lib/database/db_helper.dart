import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path;
    if (kIsWeb) {
      path = 'stardew_companion.db';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      path = join(docsDir.path, 'stardew_companion.db');
    }

    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS farms (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              farmerName TEXT NOT NULL,
              farmName TEXT NOT NULL,
              gold INTEGER NOT NULL,
              savePath TEXT NOT NULL,
              lastUpdated TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS planted_crops (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cropId TEXT NOT NULL,
              cropName TEXT NOT NULL,
              season TEXT NOT NULL,
              quantity INTEGER NOT NULL,
              plantDay INTEGER NOT NULL,
              alreadyPlanted INTEGER DEFAULT 0,
              daysUntilFirstHarvest INTEGER DEFAULT 0,
              exactFirstHarvestDay INTEGER,
              fertilizer TEXT DEFAULT 'none',
              processingMethod TEXT DEFAULT 'keg',
              notes TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE planted_crops ADD COLUMN exactFirstHarvestDay INTEGER');
          } catch (_) {}
        }
        if (oldVersion < 5) {
          try {
            await db.execute("ALTER TABLE tasks ADD COLUMN farmKey TEXT DEFAULT 'global'");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE planted_crops ADD COLUMN farmKey TEXT DEFAULT 'global'");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE ledger ADD COLUMN farmKey TEXT DEFAULT 'global'");
          } catch (_) {}
          try {
            await db.execute("ALTER TABLE custom_crops ADD COLUMN farmKey TEXT DEFAULT 'global'");
          } catch (_) {}
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        farmKey TEXT DEFAULT 'global'
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        season TEXT NOT NULL,
        day INTEGER NOT NULL,
        year INTEGER DEFAULT 1,
        isCompleted INTEGER DEFAULT 0,
        category TEXT DEFAULT 'General',
        farmKey TEXT DEFAULT 'global'
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_crops (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        season TEXT NOT NULL,
        seedCost REAL NOT NULL,
        baseSellPrice REAL NOT NULL,
        daysToGrow INTEGER NOT NULL,
        regrowDays INTEGER DEFAULT 0,
        sourceMod TEXT DEFAULT 'Custom',
        farmKey TEXT DEFAULT 'global'
      )
    ''');

    await db.execute('''
      CREATE TABLE farms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmerName TEXT NOT NULL,
        farmName TEXT NOT NULL,
        gold INTEGER NOT NULL,
        savePath TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE planted_crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cropId TEXT NOT NULL,
        cropName TEXT NOT NULL,
        season TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        plantDay INTEGER NOT NULL,
        alreadyPlanted INTEGER DEFAULT 0,
        daysUntilFirstHarvest INTEGER DEFAULT 0,
        exactFirstHarvestDay INTEGER,
        fertilizer TEXT DEFAULT 'none',
        processingMethod TEXT DEFAULT 'keg',
        notes TEXT,
        farmKey TEXT DEFAULT 'global'
      )
    ''');
  }

  // --- Operaciones de Granja / Saves ---
  static Future<int> saveFarmRecord({
    required String farmerName,
    required String farmName,
    required int gold,
    required String savePath,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(
      'farms',
      where: 'farmerName = ? AND farmName = ?',
      whereArgs: [farmerName, farmName],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'farms',
        {'gold': gold, 'savePath': savePath, 'lastUpdated': now},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      return await db.insert('farms', {
        'farmerName': farmerName,
        'farmName': farmName,
        'gold': gold,
        'savePath': savePath,
        'lastUpdated': now,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedFarms() async {
    final db = await database;
    return await db.query('farms', orderBy: 'id DESC');
  }

  // --- Operaciones de Contabilidad por Granja ---
  static Future<int> insertLedger(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('ledger', row);
  }

  static Future<List<Map<String, dynamic>>> getLedgerEntries({String? farmKey}) async {
    final db = await database;
    if (farmKey == null || farmKey.isEmpty) {
      return await db.query('ledger', orderBy: 'id DESC');
    }
    return await db.query(
      'ledger',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
      orderBy: 'id DESC',
    );
  }

  static Future<int> deleteLedgerEntry(int id) async {
    final db = await database;
    return await db.delete('ledger', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Tareas por Granja ---
  static Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('tasks', row);
  }

  static Future<List<Map<String, dynamic>>> getTasks({String? farmKey}) async {
    final db = await database;
    if (farmKey == null || farmKey.isEmpty) {
      return await db.query('tasks', orderBy: 'id DESC');
    }
    return await db.query(
      'tasks',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
      orderBy: 'id DESC',
    );
  }

  static Future<int> updateTaskStatus(int id, bool isCompleted) async {
    final db = await database;
    return await db.update('tasks', {'isCompleted': isCompleted ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Cultivos de Mods ---
  static Future<int> insertCustomCrop(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('custom_crops', row);
  }

  static Future<List<Map<String, dynamic>>> getCustomCrops({String? farmKey}) async {
    final db = await database;
    if (farmKey == null || farmKey.isEmpty) {
      return await db.query('custom_crops');
    }
    return await db.query(
      'custom_crops',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
    );
  }

  // --- Operaciones de Ajustes / Preferencias Persistentes ---
  static Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT)');
    await db.insert('app_settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String?> getSetting(String key) async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT)');
    final res = await db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    if (res.isNotEmpty) {
      return res.first['value'] as String?;
    }
    return null;
  }
}
