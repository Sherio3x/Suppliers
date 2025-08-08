import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/models/payment.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';
import 'package:supplier_invoice_app/screens/add_edit_payment_screen.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الفاتورة"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    "معلومات الفاتورة",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text("نوع المنتج: ${widget.invoice.productType}"),
                  Text("الإجمالي: ${widget.invoice.total} ريال"),
                  Text("نوع الدفع: ${widget.invoice.paymentType}"),
                  Text("التاريخ: ${widget.invoice.date.day}/${widget.invoice.date.month}/${widget.invoice.date.year}"),
                ],
              ),
            ),
          ),
          if (widget.invoice.paymentType == "أجل") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "المدفوعات",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  FutureBuilder<double>(
                    future: _realtimeDatabaseService.getRemainingBalance(widget.invoice.id!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "الرصيد المتبقي: ${snapshot.data!.toStringAsFixed(2)} ريال",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: snapshot.data! > 0 ? Colors.red : Colors.green,
                          ),
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Payment>>(
                stream: _realtimeDatabaseService.getPaymentsByInvoice(widget.invoice.id!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("خطأ: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Payment> payments = snapshot.data ?? [];

                  if (payments.isEmpty) {
                    return const Center(child: Text("لا توجد مدفوعات لهذه الفاتورة."));
                  }

                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      Payment payment = payments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          title: Text("${payment.amount} ريال"),
                          subtitle: Text("${payment.date.day}/${payment.date.month}/${payment.date.year}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditPaymentScreen(
                                        payment: payment,
                                        invoiceId: widget.invoice.id!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _realtimeDatabaseService.deletePayment(payment.id!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Text("هذه فاتورة نقدية، لا تحتاج إلى مدفوعات."),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: widget.invoice.paymentType == "أجل"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditPaymentScreen(invoiceId: widget.invoice.id!),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

