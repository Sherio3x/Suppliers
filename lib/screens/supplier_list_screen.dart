import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/firestore_service.dart';
import 'package:supplier_invoice_app/screens/add_edit_supplier_screen.dart';
import 'package:supplier_invoice_app/screens/supplier_details_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموردون'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Supplier>>(
        stream: _firestoreService.getSuppliers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Supplier> suppliers = snapshot.data ?? [];

          if (suppliers.isEmpty) {
            return const Center(child: Text('لا يوجد موردون حتى الآن.'));
          }

          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              Supplier supplier = suppliers[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(supplier.name),
                  subtitle: Text(supplier.productType),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditSupplierScreen(supplier: supplier),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _firestoreService.deleteSupplier(supplier.id!); 
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupplierDetailsScreen(supplier: supplier),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditSupplierScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
