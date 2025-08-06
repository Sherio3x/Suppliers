import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      productType: data['productType'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      paymentType: data['paymentType'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierId': supplierId,
      'productType': productType,
      'total': total,
      'paymentType': paymentType,
      'date': Timestamp.fromDate(date),
    };
  }
}

