import 'package:flutter/foundation.dart';
import '../core/database/task_dao.dart';

/// Provider de tareas del calendario del granjero.
///
/// Optimizado con mutaciones O(1) en memoria para evitar
/// consultas masivas a SQLite en cada interacción.
class TaskProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [];
  String _currentFarmKey = 'global';

  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);
  String get currentFarmKey => _currentFarmKey;

  TaskProvider() {
    refreshTasks(shouldNotify: false);
  }

  Future<void> setFarmKey(String farmKey) async {
    _currentFarmKey = farmKey;
    await refreshTasks();
  }

  Future<void> refreshTasks({bool shouldNotify = true}) async {
    _tasks = await TaskDao.getAll(farmKey: _currentFarmKey);
    if (shouldNotify) notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String season,
    required int day,
    String category = 'General',
  }) async {
    final row = {
      'title': title,
      'season': season,
      'day': day,
      'year': 1,
      'isCompleted': 0,
      'category': category,
      'farmKey': _currentFarmKey,
    };
    final id = await TaskDao.insert(row);

    final newTask = {
      'id': id,
      ...row,
    };

    // Actualización O(1) en memoria + notificación inmediata
    _tasks = [newTask, ..._tasks];
    notifyListeners();
  }

  Future<void> toggleTask(int id, bool currentStatus) async {
    final newStatus = !currentStatus;
    await TaskDao.updateStatus(id, newStatus);

    final index = _tasks.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_tasks[index]);
      updated['isCompleted'] = newStatus ? 1 : 0;
      final newList = List<Map<String, dynamic>>.from(_tasks);
      newList[index] = updated;
      _tasks = newList;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await TaskDao.delete(id);
    _tasks = _tasks.where((t) => t['id'] != id).toList();
    notifyListeners();
  }
}
