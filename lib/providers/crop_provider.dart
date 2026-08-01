import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/crop_model.dart';
import '../models/default_stardew_data.dart';

/// Provider de cultivos: datos vanilla + cultivos custom del usuario.
///
/// Fix del bug de ID inconsistente:
/// [addCustomCrop] ahora recarga los cultivos desde la BD tras insertar,
/// garantizando que el ID en memoria coincida con el ID de la base de datos.
class CropProvider extends ChangeNotifier {
  List<CropModel> _allCrops = [];

  List<CropModel> get allCrops => List.unmodifiable(_allCrops);

  /// Retorna todos los cultivos o solo los Vanilla si la granja no usa mods.
  List<CropModel> getCropsForFarm({bool includeModCrops = true}) {
    if (includeModCrops) {
      return List.unmodifiable(_allCrops);
    }
    return List.unmodifiable(_allCrops.where((c) => c.sourceMod == 'Vanilla'));
  }

  CropProvider() {
    _init();
  }

  Future<void> _init() async {
    _allCrops = List.from(DefaultStardewData.defaultCrops);
    await _loadCustomCrops(shouldNotify: false);
    notifyListeners();
  }

  Future<void> _loadCustomCrops({bool shouldNotify = true}) async {
    // Eliminar cultivos custom previos antes de recargar desde BD
    _allCrops.removeWhere((c) => c.id.startsWith('custom_'));

    final customList = await DBHelper.getCustomCrops();
    for (final map in customList) {
      _allCrops.add(CropModel(
        id: 'custom_${map['id']}', // Usa el ID real de la BD
        name: map['name'],
        season: map['season'],
        seedCost: (map['seedCost'] as num).toDouble(),
        baseSellPrice: (map['sellPrice'] as num).toDouble(),
        daysToGrow: map['daysToGrow'] as int,
        regrowDays: map['regrowDays'] as int,
        sourceMod: map['sourceMod'] ?? 'Custom Mod',
      ));
    }
    if (shouldNotify) notifyListeners();
  }

  /// Agrega un cultivo custom a la BD y recarga desde ella para mantener IDs consistentes.
  Future<void> addCustomCrop({
    required String name,
    required String season,
    required double seedCost,
    required double sellPrice,
    required int daysToGrow,
    int regrowDays = 0,
    required String sourceMod,
  }) async {
    await DBHelper.insertCustomCrop({
      'name': name,
      'season': season,
      'seedCost': seedCost,
      'sellPrice': sellPrice,
      'daysToGrow': daysToGrow,
      'regrowDays': regrowDays,
      'sourceMod': sourceMod,
    });
    // Recarga desde BD para obtener el ID real — fix del bug de ID inconsistente
    await _loadCustomCrops();
  }
}
