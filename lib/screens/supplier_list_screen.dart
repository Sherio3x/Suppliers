import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';
import 'package:supplier_invoice_app/screens/add_edit_supplier_screen.dart';
import 'package:supplier_invoice_app/screens/supplier_details_screen.dart';
import 'package:supplier_invoice_app/notifiers/supplier_list_notifier.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierListNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الموردون'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: StreamBuilder<List<Supplier>>(
          stream: _realtimeDatabaseService.getSuppliers(),
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
                    trailing: Consumer<SupplierListNotifier>(
                      builder: (context, notifier, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.MainAxisSize.min,
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
                              onPressed: notifier.deleteState == SupplierListState.loading
                                  ? null
                                  : () async {
                                      await notifier.deleteSupplier(supplier.id!); 
                                      if (notifier.deleteState == SupplierListState.error) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('خطأ في حذف المورد: ${notifier.errorMessage}')),
                                        );
                                      }
                                    },
                            ),
                          ],
                        );
                      },
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
      ),
    );
  }
}


