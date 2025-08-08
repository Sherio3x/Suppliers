import 'package:firebase_database/firebase_database.dart';
import '../models/supplier.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // خدمات الموردين
  Stream<List<Supplier>> getSuppliers() {
    return _db.child('suppliers').onValue.map((event) {
      final List<Supplier> suppliers = [];
      final dynamic data = event.snapshot.value;
      if (data != null) {
        (data as Map).forEach((key, value) {
          suppliers.add(Supplier.fromRealtimeDatabase(key, value));
        });
      }
      return suppliers;
    });
  }

  Future<void> addSupplier(Supplier supplier) {
    final newSupplierRef = _db.child('suppliers').push();
    return newSupplierRef.set(supplier.toRealtimeDatabase());
  }

  Future<void> updateSupplier(Supplier supplier) {
    return _db.child('suppliers').child(supplier.id!).update(supplier.toRealtimeDatabase());
  }

  Future<void> deleteSupplier(String supplierId) {
    return _db.child('suppliers').child(supplierId).remove();
  }

  Future<Supplier?> getSupplier(String supplierId) async {
    final snapshot = await _db.child('suppliers').child(supplierId).get();
    if (snapshot.exists) {
      return Supplier.fromRealtimeDatabase(snapshot.key!, snapshot.value);
    }
    return null;
  }

  // خدمات الفواتير
  Stream<List<Invoice>> getInvoicesBySupplier(String supplierId) {
    return _db.child('invoices').orderByChild('supplierId').equalTo(supplierId).onValue.map((event) {
      final List<Invoice> invoices = [];
      final dynamic data = event.snapshot.value;
      if (data != null) {
        (data as Map).forEach((key, value) {
          invoices.add(Invoice.fromRealtimeDatabase(key, value));
        });
      }
      return invoices;
    });
  }

  Future<void> addInvoice(Invoice invoice) {
    final newInvoiceRef = _db.child('invoices').push();
    return newInvoiceRef.set(invoice.toRealtimeDatabase());
  }

  Future<void> updateInvoice(Invoice invoice) {
    return _db.child('invoices').child(invoice.id!).update(invoice.toRealtimeDatabase());
  }

  Future<void> deleteInvoice(String invoiceId) {
    return _db.child('invoices').child(invoiceId).remove();
  }

  Future<Invoice?> getInvoice(String invoiceId) async {
    final snapshot = await _db.child('invoices').child(invoiceId).get();
    if (snapshot.exists) {
      return Invoice.fromRealtimeDatabase(snapshot.key!, snapshot.value);
    }
    return null;
  }

  // خدمات المدفوعات
  Stream<List<Payment>> getPaymentsByInvoice(String invoiceId) {
    return _db.child('payments').orderByChild('invoiceId').equalTo(invoiceId).onValue.map((event) {
      final List<Payment> payments = [];
      final dynamic data = event.snapshot.value;
      if (data != null) {
        (data as Map).forEach((key, value) {
          payments.add(Payment.fromRealtimeDatabase(key, value));
        });
      }
      return payments;
    });
  }

  Future<void> addPayment(Payment payment) {
    final newPaymentRef = _db.child('payments').push();
    return newPaymentRef.set(payment.toRealtimeDatabase());
  }

  Future<void> updatePayment(Payment payment) {
    return _db.child('payments').child(payment.id!).update(payment.toRealtimeDatabase());
  }

  Future<void> deletePayment(String paymentId) {
    return _db.child('payments').child(paymentId).remove();
  }

  // حساب الرصيد المتبقي للفاتورة
  Future<double> getRemainingBalance(String invoiceId) async {
    Invoice? invoice = await getInvoice(invoiceId);
    if (invoice == null) return 0.0;

    final paymentsSnapshot = await _db.child('payments').orderByChild('invoiceId').equalTo(invoiceId).get();

    double totalPaid = 0.0;
    if (paymentsSnapshot.exists) {
      (paymentsSnapshot.value as Map).forEach((key, value) {
        Payment payment = Payment.fromRealtimeDatabase(key, value);
        totalPaid += payment.amount;
      });
    }

    return invoice.total - totalPaid;
  }

  // حساب ملخص المورد
  Future<Map<String, double>> getSupplierSummary(String supplierId) async {
    final invoicesSnapshot = await _db.child('invoices').orderByChild('supplierId').equalTo(supplierId).get();

    double totalInvoices = 0.0;
    double totalPaid = 0.0;

    if (invoicesSnapshot.exists) {
      (invoicesSnapshot.value as Map).forEach((invoiceKey, invoiceValue) async {
        Invoice invoice = Invoice.fromRealtimeDatabase(invoiceKey, invoiceValue);
        totalInvoices += invoice.total;

        final paymentsSnapshot = await _db.child('payments').orderByChild('invoiceId').equalTo(invoice.id).get();

        if (paymentsSnapshot.exists) {
          (paymentsSnapshot.value as Map).forEach((paymentKey, paymentValue) {
            Payment payment = Payment.fromRealtimeDatabase(paymentKey, paymentValue);
            totalPaid += payment.amount;
          });
        }
      });
    }

    return {
      'totalInvoices': totalInvoices,
      'totalPaid': totalPaid,
      'remainingBalance': totalInvoices - totalPaid,
    };
  }

  Stream<List<dynamic>> getAllMovementsForSupplier(String supplierId) {
    return _db.child('invoices').orderByChild('supplierId').equalTo(supplierId).onValue.asyncMap((invoiceEvent) async {
      List<dynamic> movements = [];
      final dynamic invoiceData = invoiceEvent.snapshot.value;

      if (invoiceData != null) {
        for (var entry in (invoiceData as Map).entries) {
          String invoiceKey = entry.key;
          Map invoiceValue = entry.value;
          Invoice invoice = Invoice.fromRealtimeDatabase(invoiceKey, invoiceValue);
          movements.add(invoice);

          final paymentsSnapshot = await _db.child('payments').orderByChild('invoiceId').equalTo(invoice.id).get();
          if (paymentsSnapshot.exists) {
            (paymentsSnapshot.value as Map).forEach((paymentKey, paymentValue) {
              Payment payment = Payment.fromRealtimeDatabase(paymentKey, paymentValue);
              movements.add(payment);
            });
          }
        }
      }
      movements.sort((a, b) {
        DateTime dateA = a is Invoice ? a.date : (a as Payment).date;
        DateTime dateB = b is Invoice ? b.date : (b as Payment).date;
        return dateA.compareTo(dateB);
      });
      return movements;
    });
  }
}


