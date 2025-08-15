import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum InvoiceFormState {
  initial,
  loading,
  success,
  error,
}

class InvoiceFormNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  InvoiceFormState _state = InvoiceFormState.initial;
  String? _errorMessage;

  InvoiceFormState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> saveInvoice(Invoice invoice) async {
    _state = InvoiceFormState.loading;
    notifyListeners();

    try {
      if (invoice.id == null) {
        await _realtimeDatabaseService.addInvoice(invoice);
      } else {
        await _realtimeDatabaseService.updateInvoice(invoice);
      }
      _state = InvoiceFormState.success;
    } catch (e) {
      _state = InvoiceFormState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

