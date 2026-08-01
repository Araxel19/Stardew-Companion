import 'dart:io';
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
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = 'stardew_companion.db';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      path = join(docsDir.path, 'stardew_companion.db');
    }

    return await openDatabase(
      path,
      version: 2,
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
        notes TEXT
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
        category TEXT DEFAULT 'General'
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        season TEXT NOT NULL,
        seedCost REAL NOT NULL,
        sellPrice REAL NOT NULL,
        daysToGrow INTEGER NOT NULL,
        regrowDays INTEGER DEFAULT 0,
        sourceMod TEXT DEFAULT 'Custom'
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
  }

  // --- Operaciones de Granjas/Partidas ---
  static Future<int> saveFarmRecord({
    required String farmerName,
    required String farmName,
    required int gold,
    required String savePath,
  }) async {
    final db = await database;
    // Evitar duplicados por savePath
    await db.delete('farms', where: 'savePath = ?', whereArgs: [savePath]);
    return await db.insert('farms', {
      'farmerName': farmerName,
      'farmName': farmName,
      'gold': gold,
      'savePath': savePath,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getSavedFarms() async {
    final db = await database;
    return await db.query('farms', orderBy: 'id DESC');
  }

  // --- Operaciones de Contabilidad ---
  static Future<int> insertLedger(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('ledger', row);
  }

  static Future<List<Map<String, dynamic>>> getLedgerEntries() async {
    final db = await database;
    return await db.query('ledger', orderBy: 'id DESC');
  }

  static Future<int> deleteLedgerEntry(int id) async {
    final db = await database;
    return await db.delete('ledger', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operaciones de Tareas ---
  static Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('tasks', row);
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'id DESC');
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

  static Future<List<Map<String, dynamic>>> getCustomCrops() async {
    final db = await database;
    return await db.query('custom_crops');
  }
}
