import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/services/firestore_service.dart';
import 'package:supplier_invoice_app/screens/add_edit_invoice_screen.dart';
import 'package:supplier_invoice_app/screens/invoice_details_screen.dart';
import 'package:supplier_invoice_app/screens/supplier_account_summary_screen.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupplierAccountSummaryScreen(supplier: widget.supplier),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات المورد',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('الاسم: ${widget.supplier.name}'),
                  Text('نوع المنتج: ${widget.supplier.productType}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Invoice>>(
              stream: _firestoreService.getInvoicesBySupplier(widget.supplier.id!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Invoice> invoices = snapshot.data ?? [];

                if (invoices.isEmpty) {
                  return const Center(child: Text('لا توجد فواتير لهذا المورد.'));
                }

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    Invoice invoice = invoices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        title: Text('${invoice.productType} - ${invoice.total} ريال'),
                        subtitle: Text('${invoice.date.day}/${invoice.date.month}/${invoice.date.year} - ${invoice.paymentType}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditInvoiceScreen(
                                      invoice: invoice,
                                      supplierId: widget.supplier.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _firestoreService.deleteInvoice(invoice.id!);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailsScreen(invoice: invoice),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditInvoiceScreen(supplierId: widget.supplier.id!),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

