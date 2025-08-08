import 'package:firebase_database/firebase_database.dart';

class Invoice {
  String? id;
  String supplierId;
  String productType;
  double total;
  String paymentType; // "نقدًا" أو "أجل"
  DateTime date;

  Invoice({
    this.id,
    required this.supplierId,
    required this.productType,
    required this.total,
    required this.paymentType,
    required this.date,
  });

  factory Invoice.fromRealtimeDatabase(String id, dynamic data) {
    return Invoice(
      id: id,
      supplierId: data['supplierId'] ?? '',
      productType: data['productType'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      paymentType: data['paymentType'] ?? '',
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toRealtimeDatabase() {
    return {
      'supplierId': supplierId,
      'productType': productType,
      'total': total,
      'paymentType': paymentType,
      'date': date.toIso8601String(),
    };
  }
}
