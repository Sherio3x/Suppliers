import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/models/payment.dart';

enum SummaryState {
  initial,
  loading,
  success,
  error,
}

class SupplierAccountSummaryNotifier extends ChangeNotifier {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  SummaryState _summaryState = SummaryState.initial;
  SummaryState _movementsState = SummaryState.initial;
  String? _errorMessage;

  Map<String, double>? _summaryData;
  List<dynamic>? _movementsData;

  SummaryState get summaryState => _summaryState;
  SummaryState get movementsState => _movementsState;
  String? get errorMessage => _errorMessage;
  Map<String, double>? get summaryData => _summaryData;
  List<dynamic>? get movementsData => _movementsData;

  Future<void> fetchSummary(String supplierId) async {
    _summaryState = SummaryState.loading;
    notifyListeners();
    try {
      _summaryData = await _realtimeDatabaseService.getSupplierSummary(supplierId);
      _summaryState = SummaryState.success;
    } catch (e) {
      _summaryState = SummaryState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Stream<List<dynamic>> getMovements(String supplierId) {
    return _realtimeDatabaseService.getAllMovementsForSupplier(supplierId).map((movements) {
      _movementsState = SummaryState.success;
      _movementsData = movements;
      notifyListeners();
      return movements;
    }).handleError((e) {
      _movementsState = SummaryState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    });
  }
}

