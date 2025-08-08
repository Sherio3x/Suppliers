import 'package:firebase_database/firebase_database.dart';

class Supplier {
  String? id;
  String name;
  String productType;

  Supplier({
    this.id,
    required this.name,
    required this.productType,
  });

  factory Supplier.fromRealtimeDatabase(String id, dynamic data) {
    return Supplier(
      id: id,
      name: data['name'] ?? '',
      productType: data['productType'] ?? '',
    );
  }

  Map<String, dynamic> toRealtimeDatabase() {
    return {
      'name': name,
      'productType': productType,
    };
  }
}
