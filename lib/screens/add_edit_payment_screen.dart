import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_invoice_app/models/payment.dart';
import 'package:supplier_invoice_app/notifiers/payment_form_notifier.dart';

class AddEditPaymentScreen extends StatefulWidget {
  final Payment? payment;
  final String invoiceId;

  const AddEditPaymentScreen({super.key, this.payment, required this.invoiceId});

  @override
  State<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends State<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _amountController.text = widget.payment!.amount.toString();
      _selectedDate = widget.payment!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _savePayment(PaymentFormNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      Payment payment = Payment(
        id: widget.payment?.id,
        invoiceId: widget.invoiceId,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
      );

      await notifier.savePayment(payment);

      if (notifier.state == PaymentFormState.success) {
        Navigator.pop(context);
      } else if (notifier.state == PaymentFormState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ البيانات: ${notifier.errorMessage}'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentFormNotifier(),
      child: Consumer<PaymentFormNotifier>(
        builder: (context, notifier, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.payment == null ? 'إضافة دفع' : 'تعديل دفع'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال المبلغ';
                        }
                        if (double.tryParse(value) == null) {
                          return 'يرجى إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'التاريخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: notifier.state == PaymentFormState.loading
                          ? null
                          : () => _savePayment(notifier),
                      child: notifier.state == PaymentFormState.loading
                          ? const CircularProgressIndicator()
                          : Text(widget.payment == null ? 'إضافة' : 'تحديث'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


