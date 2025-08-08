import 'package:firebase_database/firebase_database.dart';

class Payment {
  String? id;
  String invoiceId;
  double amount;
  DateTime date;

  Payment({
    this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
  });

  factory Payment.fromRealtimeDatabase(String id, dynamic data) {
    return Payment(
      id: id,
      invoiceId: data['invoiceId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toRealtimeDatabase() {
    return {
      'invoiceId': invoiceId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
