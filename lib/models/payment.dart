import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      invoiceId: data['invoiceId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'invoiceId': invoiceId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}

