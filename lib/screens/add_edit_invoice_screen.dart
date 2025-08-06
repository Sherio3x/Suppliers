import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/invoice.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/firestore_service.dart';

class AddEditInvoiceScreen extends StatefulWidget {
  final Invoice? invoice;
  final String supplierId;

  const AddEditInvoiceScreen({super.key, this.invoice, required this.supplierId});

  @override
  State<AddEditInvoiceScreen> createState() => _AddEditInvoiceScreenState();
}

class _AddEditInvoiceScreenState extends State<AddEditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productTypeController = TextEditingController();
  final _totalController = TextEditingController();
  String _paymentType = 'نقدًا';
  DateTime _selectedDate = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _productTypeController.text = widget.invoice!.productType;
      _totalController.text = widget.invoice!.total.toString();
      _paymentType = widget.invoice!.paymentType;
      _selectedDate = widget.invoice!.date;
    }
  }

  @override
  void dispose() {
    _productTypeController.dispose();
    _totalController.dispose();
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

  void _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      Invoice invoice = Invoice(
        id: widget.invoice?.id,
        supplierId: widget.supplierId,
        productType: _productTypeController.text,
        total: double.parse(_totalController.text),
        paymentType: _paymentType,
        date: _selectedDate,
      );

      try {
        if (widget.invoice == null) {
          await _firestoreService.addInvoice(invoice);
        } else {
          await _firestoreService.updateInvoice(invoice);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ البيانات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'إضافة فاتورة' : 'تعديل فاتورة'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productTypeController,
                decoration: const InputDecoration(
                  labelText: 'نوع المنتج',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نوع المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الإجمالي',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الإجمالي';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(
                  labelText: 'نوع الدفع',
                  border: OutlineInputBorder(),
                ),
                items: <String>['نقدًا', 'أجل']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentType = newValue!;
                  });
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
                onPressed: _saveInvoice,
                child: Text(widget.invoice == null ? 'إضافة' : 'تحديث'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

