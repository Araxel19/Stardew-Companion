import 'package:flutter/foundation.dart';
import '../core/database/planted_crop_dao.dart';
import '../models/planted_crop_model.dart';

/// Provider optimizado que gestiona los lotes de cultivos plantados.
///
/// Implementa mutaciones reactivas O(1) en memoria para máximo rendimiento.
class PlantedCropProvider extends ChangeNotifier {
  List<PlantedCropBatch> _batches = [];
  String _currentFarmKey = 'global';

  List<PlantedCropBatch> get batches => List.unmodifiable(_batches);
  String get currentFarmKey => _currentFarmKey;

  PlantedCropProvider() {
    refreshBatches(shouldNotify: false);
  }

  Future<void> setFarmKey(String farmKey) async {
    _currentFarmKey = farmKey;
    await refreshBatches();
  }

  Future<void> refreshBatches({bool shouldNotify = true}) async {
    final list = await PlantedCropDao.getAll(farmKey: _currentFarmKey);
    _batches = list.map((map) => PlantedCropBatch.fromMap(map)).toList();
    if (shouldNotify) notifyListeners();
  }

  Future<void> addBatch(PlantedCropBatch batch) async {
    final batchWithKey = batch.farmKey == 'global' && _currentFarmKey != 'global'
        ? batch.copyWith(farmKey: _currentFarmKey)
        : batch;
    final id = await PlantedCropDao.insert(batchWithKey.toMap());
    final newBatch = batchWithKey.copyWith(id: id);
    _batches = [newBatch, ..._batches];
    notifyListeners();
  }

  Future<void> updateBatch(PlantedCropBatch batch) async {
    if (batch.id == null) return;
    await PlantedCropDao.update(batch.id!, batch.toMap());
    final index = _batches.indexWhere((b) => b.id == batch.id);
    if (index != -1) {
      final newList = List<PlantedCropBatch>.from(_batches);
      newList[index] = batch;
      _batches = newList;
      notifyListeners();
    }
  }

  Future<void> deleteBatch(int id) async {
    await PlantedCropDao.delete(id);
    _batches = _batches.where((b) => b.id != id).toList();
    notifyListeners();
  }
}
