import '../../database/db_helper.dart';

/// DAO para cultivos personalizados (creados por el usuario).
///
/// Incluye fix del bug de ID inconsistente:
/// [insert] devuelve el ID asignado por la base de datos,
/// y [getAll] carga todos los cultivos con el ID real de BD.
class CustomCropDao {
/// Retorna todos los cultivos custom, usando el ID de BD como `custom_<id>`.
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DBHelper.database;
    return db.query('custom_crops', orderBy: 'id ASC');
  }

  /// Inserta un cultivo y retorna el ID asignado por la BD.
  Future<int> insert({
    required String name,
    required String season,
    required double seedCost,
    required double baseSellPrice,
    required int daysToGrow,
    required int regrowDays,
    required String sourceMod,
  }) async {
    final db = await DBHelper.database;
    return db.insert('custom_crops', {
      'name': name,
      'season': season,
      'seedCost': seedCost,
      'baseSellPrice': baseSellPrice,
      'daysToGrow': daysToGrow,
      'regrowDays': regrowDays,
      'sourceMod': sourceMod,
    });
  }

  Future<int> delete(int id) async {
    final db = await DBHelper.database;
    return db.delete('custom_crops', where: 'id = ?', whereArgs: [id]);
  }
}



