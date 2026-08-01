import '../../database/db_helper.dart';

/// DAO para el registro de granjas guardadas localmente.
class FarmDao {
Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DBHelper.database;
    return db.query('farms', orderBy: 'lastModified DESC');
  }

  /// Inserta o actualiza (upsert) una granja por su [filePath].
  Future<void> upsert({
    required String farmerName,
    required String farmName,
    required String filePath,
    required int currentMoney,
    required String gameSeason,
    required int gameYear,
  }) async {
    final db = await DBHelper.database;
    final existing = await db.query(
      'farms',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
    final now = DateTime.now().toIso8601String();
    if (existing.isEmpty) {
      await db.insert('farms', {
        'farmerName': farmerName,
        'farmName': farmName,
        'filePath': filePath,
        'currentMoney': currentMoney,
        'gameSeason': gameSeason,
        'gameYear': gameYear,
        'lastModified': now,
      });
    } else {
      await db.update(
        'farms',
        {
          'farmerName': farmerName,
          'farmName': farmName,
          'currentMoney': currentMoney,
          'gameSeason': gameSeason,
          'gameYear': gameYear,
          'lastModified': now,
        },
        where: 'filePath = ?',
        whereArgs: [filePath],
      );
    }
  }

  Future<int> delete(String filePath) async {
    final db = await DBHelper.database;
    return db.delete('farms', where: 'filePath = ?', whereArgs: [filePath]);
  }
}



