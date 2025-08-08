import 'package:flutter/material.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final Supplier? supplier;

  const AddEditSupplierScreen({super.key, this.supplier});

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _productTypeController = TextEditingController();
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _productTypeController.text = widget.supplier!.productType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  void _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      Supplier supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text,
        productType: _productTypeController.text,
      );

      try {
        if (widget.supplier == null) {
          await _realtimeDatabaseService.addSupplier(supplier);
        } else {
          await _realtimeDatabaseService.updateSupplier(supplier);
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
        title: Text(widget.supplier == null ? 'إضافة مورد' : 'تعديل مورد'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المورد',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المورد';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSupplier,
                child: Text(widget.supplier == null ? 'إضافة' : 'تحديث'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

