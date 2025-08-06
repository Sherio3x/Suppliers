import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/firestore_service.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/models/payment.dart';

class SupplierAccountSummaryScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierAccountSummaryScreen({super.key, required this.supplier});

  @override
  State<SupplierAccountSummaryScreen> createState() => _SupplierAccountSummaryScreenState();
}

class _SupplierAccountSummaryScreenState extends State<SupplierAccountSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملخص حساب ${widget.supplier.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, double>>(
              future: _firestoreService.getSupplierSummary(widget.supplier.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد بيانات ملخص لهذا المورد.'));
                }

                final summary = snapshot.data!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص الحساب',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('القيمة الإجمالية للفواتير: ${summary['totalInvoices']!.toStringAsFixed(2)} ريال'),
                        Text('إجمالي المدفوعات المستلمة: ${summary['totalPaid']!.toStringAsFixed(2)} ريال'),
                        Text(
                          'الرصيد المتبقي: ${summary['remainingBalance']!.toStringAsFixed(2)} ريال',
                          style: TextStyle(
                            color: summary['remainingBalance']! > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Text(
              'جميع الحركات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: _firestoreService.getAllMovementsForSupplier(widget.supplier.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('خطأ: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد حركات لهذا المورد.'));
                  }

                  final movements = snapshot.data!;
                  return ListView.builder(
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final movement = movements[index];
                      if (movement is Invoice) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text('فاتورة: ${movement.productType}'),
                            subtitle: Text('التاريخ: ${movement.date.day}/${movement.date.month}/${movement.date.year} | النوع: ${movement.paymentType}'),
                            trailing: Text('${movement.total.toStringAsFixed(2)} ريال (داخل)', style: const TextStyle(color: Colors.green)),
                          ),
                        );
                      } else if (movement is Payment) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: const Text('دفع'),
                            subtitle: Text('التاريخ: ${movement.date.day}/${movement.date.month}/${movement.date.year}'),
                            trailing: Text('${movement.amount.toStringAsFixed(2)} ريال (خارج)', style: const TextStyle(color: Colors.red)),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


