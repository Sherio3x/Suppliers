import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum SupplierFormState {
  initial,
  loading,
  success,
  error,
}

class SupplierFormNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  SupplierFormState _state = SupplierFormState.initial;
  String? _errorMessage;

  SupplierFormState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> saveSupplier(Supplier supplier) async {
    _state = SupplierFormState.loading;
    notifyListeners();

    try {
      if (supplier.id == null) {
        await _realtimeDatabaseService.addSupplier(supplier);
      } else {
        await _realtimeDatabaseService.updateSupplier(supplier);
      }
      _state = SupplierFormState.success;
    } catch (e) {
      _state = SupplierFormState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

