import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_invoice_app/models/supplier.dart';
import 'package:supplier_invoice_app/notifiers/supplier_form_notifier.dart';

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

  void _saveSupplier(SupplierFormNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      Supplier supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text,
        productType: _productTypeController.text,
      );

      await notifier.saveSupplier(supplier);

      if (notifier.state == SupplierFormState.success) {
        Navigator.pop(context);
      } else if (notifier.state == SupplierFormState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ البيانات: ${notifier.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierFormNotifier(),
      child: Consumer<SupplierFormNotifier>(
        builder: (context, notifier, child) {
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
                      onPressed: notifier.state == SupplierFormState.loading
                          ? null
                          : () => _saveSupplier(notifier),
                      child: notifier.state == SupplierFormState.loading
                          ? const CircularProgressIndicator()
                          : Text(widget.supplier == null ? 'إضافة' : 'تحديث'),
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


