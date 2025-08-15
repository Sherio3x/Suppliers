import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum InvoiceListState {
  initial,
  loading,
  success,
  error,
}

class InvoiceListNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  InvoiceListState _deleteState = InvoiceListState.initial;
  String? _errorMessage;

  InvoiceListState get deleteState => _deleteState;
  String? get errorMessage => _errorMessage;

  Future<void> deleteInvoice(String invoiceId) async {
    _deleteState = InvoiceListState.loading;
    notifyListeners();

    try {
      await _realtimeDatabaseService.deleteInvoice(invoiceId);
      _deleteState = InvoiceListState.success;
    } catch (e) {
      _deleteState = InvoiceListState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

