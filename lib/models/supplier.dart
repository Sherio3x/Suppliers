import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  String? id;
  String name;
  String productType;

  Supplier({
    this.id,
    required this.name,
    required this.productType,
  });

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['name'] ?? '',
      productType: data['productType'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'productType': productType,
    };
  }
}


