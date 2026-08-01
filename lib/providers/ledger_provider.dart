import 'package:flutter/foundation.dart';
import '../core/database/ledger_dao.dart';

/// Provider del libro mayor de ganancias y gastos.
///
/// Optimizado con mutación directa en memoria O(1).
class LedgerProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _ledgerEntries = [];
  String _currentFarmKey = 'global';

  List<Map<String, dynamic>> get ledgerEntries =>
      List.unmodifiable(_ledgerEntries);
  String get currentFarmKey => _currentFarmKey;

  LedgerProvider() {
    refreshLedger(shouldNotify: false);
  }

  Future<void> setFarmKey(String farmKey) async {
    _currentFarmKey = farmKey;
    await refreshLedger();
  }

  Future<void> refreshLedger({bool shouldNotify = true}) async {
    _ledgerEntries = await LedgerDao.getAll(farmKey: _currentFarmKey);
    if (shouldNotify) notifyListeners();
  }

  Future<void> addLedgerEntry({
    required String title,
    required String type,
    required String category,
    required double amount,
    required String date,
    String? notes,
  }) async {
    final row = {
      'title': title,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes ?? '',
      'farmKey': _currentFarmKey,
    };
    final id = await LedgerDao.insert(row);

    final newEntry = {
      'id': id,
      ...row,
    };

    _ledgerEntries = [newEntry, ..._ledgerEntries];
    notifyListeners();
  }

  Future<void> deleteLedgerEntry(int id) async {
    await LedgerDao.delete(id);
    _ledgerEntries = _ledgerEntries.where((e) => e['id'] != id).toList();
    notifyListeners();
  }
}
