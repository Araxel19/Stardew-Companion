import '../../database/db_helper.dart';

/// DAO (Data Access Object) para entradas del libro mayor de ganancias/gastos.
class LedgerDao {
  static Future<List<Map<String, dynamic>>> getAll({String? farmKey}) async {
    final db = await DBHelper.database;
    if (farmKey == null || farmKey.isEmpty) {
      return db.query('ledger', orderBy: 'id DESC');
    }
    return db.query(
      'ledger',
      where: "farmKey = ? OR farmKey IS NULL OR farmKey = 'global'",
      whereArgs: [farmKey],
      orderBy: 'id DESC',
    );
  }

  static Future<int> insert(Map<String, dynamic> row) async {
    final db = await DBHelper.database;
    return db.insert('ledger', row);
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('ledger', where: 'id = ?', whereArgs: [id]);
  }
}
