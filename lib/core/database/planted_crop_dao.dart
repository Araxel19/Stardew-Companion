import '../../database/db_helper.dart';

/// DAO para la persistencia de lotes de cultivos plantados.
class PlantedCropDao {
  static Future<List<Map<String, dynamic>>> getAll({String? farmKey}) async {
    final db = await DBHelper.database;
    if (farmKey == null || farmKey.isEmpty) {
      return db.query('planted_crops', orderBy: 'id DESC');
    }
    return db.query(
      'planted_crops',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
      orderBy: 'id DESC',
    );
  }

  static Future<int> insert(Map<String, dynamic> row) async {
    final db = await DBHelper.database;
    return db.insert('planted_crops', row);
  }

  static Future<int> update(int id, Map<String, dynamic> row) async {
    final db = await DBHelper.database;
    return db.update('planted_crops', row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('planted_crops', where: 'id = ?', whereArgs: [id]);
  }
}
