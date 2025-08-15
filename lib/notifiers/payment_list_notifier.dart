import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum PaymentListState {
  initial,
  loading,
  success,
  error,
}

class PaymentListNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  PaymentListState _deleteState = PaymentListState.initial;
  String? _errorMessage;

  PaymentListState get deleteState => _deleteState;
  String? get errorMessage => _errorMessage;

  Future<void> deletePayment(String paymentId) async {
    _deleteState = PaymentListState.loading;
    notifyListeners();

    try {
      await _realtimeDatabaseService.deletePayment(paymentId);
      _deleteState = PaymentListState.success;
    } catch (e) {
      _deleteState = PaymentListState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

