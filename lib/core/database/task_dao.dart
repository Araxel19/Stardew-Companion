import '../../database/db_helper.dart';

/// DAO para tareas del calendario del granjero.
class TaskDao {
  static Future<List<Map<String, dynamic>>> getAll({String? farmKey}) async {
    final db = await DBHelper.database;
    if (farmKey == null || farmKey.isEmpty) {
      return db.query('tasks', orderBy: 'id ASC');
    }
    return db.query(
      'tasks',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
      orderBy: 'id ASC',
    );
  }

  static Future<int> insert(Map<String, dynamic> row) async {
    final db = await DBHelper.database;
    return db.insert('tasks', row);
  }

  static Future<int> updateStatus(int id, bool isCompleted) async {
    final db = await DBHelper.database;
    return db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
