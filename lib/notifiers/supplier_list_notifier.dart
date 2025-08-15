import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum SupplierListState {
  initial,
  loading,
  success,
  error,
}

class SupplierListNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  SupplierListState _deleteState = SupplierListState.initial;
  String? _errorMessage;

  SupplierListState get deleteState => _deleteState;
  String? get errorMessage => _errorMessage;

  Future<void> deleteSupplier(String supplierId) async {
    _deleteState = SupplierListState.loading;
    notifyListeners();

    try {
      await _realtimeDatabaseService.deleteSupplier(supplierId);
      _deleteState = SupplierListState.success;
    } catch (e) {
      _deleteState = SupplierListState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

