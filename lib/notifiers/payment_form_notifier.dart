import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/payment.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

enum PaymentFormState {
  initial,
  loading,
  success,
  error,
}

class PaymentFormNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  PaymentFormState _state = PaymentFormState.initial;
  String? _errorMessage;

  PaymentFormState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> savePayment(Payment payment) async {
    _state = PaymentFormState.loading;
    notifyListeners();

    try {
      if (payment.id == null) {
        await _realtimeDatabaseService.addPayment(payment);
      } else {
        await _realtimeDatabaseService.updatePayment(payment);
      }
      _state = PaymentFormState.success;
    } catch (e) {
      _state = PaymentFormState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}

