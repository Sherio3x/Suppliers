import 'package:firebase_database/firebase_database.dart';
import '../models/supplier.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // دوال عامة لعمليات CRUD
  Future<void> _add<T>(String path, T item, Function(T) toRealtimeDatabase) {
    final newRef = _db.child(path).push();
    if (item is Supplier) {
      item.id = newRef.key; // تعيين الـ ID للمورد
    } else if (item is Invoice) {
      item.id = newRef.key; // تعيين الـ ID للفاتورة
    } else if (item is Payment) {
      item.id = newRef.key; // تعيين الـ ID للدفع
    }
    return newRef.set(toRealtimeDatabase(item));
  }

  Future<void> _update<T>(String path, T item, Function(T) toRealtimeDatabase) {
    String? id;
    if (item is Supplier) {
      id = item.id;
    } else if (item is Invoice) {
      id = item.id;
    } else if (item is Payment) {
      id = item.id;
    }
    if (id == null) {
      return Future.error('ID cannot be null for update operation');
    }
    return _db.child(path).child(id).update(toRealtimeDatabase(item));
  }

  Future<void> _delete(String path, String id) {
    return _db.child(path).child(id).remove();
  }

  Stream<List<T>> _getStream<T>(String path, T Function(String, dynamic) fromRealtimeDatabase, {String? orderByChild, String? equalTo}) {
    Query query = _db.child(path);
    if (orderByChild != null && equalTo != null) {
      query = query.orderByChild(orderByChild).equalTo(equalTo);
    }
    return query.onValue.map((event) {
      final List<T> items = [];
      final dynamic data = event.snapshot.value;
      if (data != null) {
        (data as Map).forEach((key, value) {
          items.add(fromRealtimeDatabase(key, value));
        });
      }
      return items;
    });
  }

  Future<T?> _getSingle<T>(String path, String id, T Function(String, dynamic) fromRealtimeDatabase) async {
    final snapshot = await _db.child(path).child(id).get();
    if (snapshot.exists) {
      return fromRealtimeDatabase(snapshot.key!, snapshot.value);
    }
    return null;
  }

  // خدمات الموردين
  Stream<List<Supplier>> getSuppliers() => _getStream<Supplier>('suppliers', Supplier.fromRealtimeDatabase);
  Future<void> addSupplier(Supplier supplier) => _add<Supplier>('suppliers', supplier, (s) => s.toRealtimeDatabase());
  Future<void> updateSupplier(Supplier supplier) => _update<Supplier>('suppliers', supplier, (s) => s.toRealtimeDatabase());
  Future<void> deleteSupplier(String supplierId) => _delete('suppliers', supplierId);
  Future<Supplier?> getSupplier(String supplierId) => _getSingle<Supplier>('suppliers', supplierId, Supplier.fromRealtimeDatabase);

  // خدمات الفواتير
  Stream<List<Invoice>> getInvoicesBySupplier(String supplierId) => _getStream<Invoice>('invoices', Invoice.fromRealtimeDatabase, orderByChild: 'supplierId', equalTo: supplierId);
  Future<void> addInvoice(Invoice invoice) => _add<Invoice>('invoices', invoice, (i) => i.toRealtimeDatabase());
  Future<void> updateInvoice(Invoice invoice) => _update<Invoice>('invoices', invoice, (i) => i.toRealtimeDatabase());
  Future<void> deleteInvoice(String invoiceId) => _delete('invoices', invoiceId);
  Future<Invoice?> getInvoice(String invoiceId) => _getSingle<Invoice>('invoices', invoiceId, Invoice.fromRealtimeDatabase);

  // خدمات المدفوعات
  Stream<List<Payment>> getPaymentsByInvoice(String invoiceId) => _getStream<Payment>('payments', Payment.fromRealtimeDatabase, orderByChild: 'invoiceId', equalTo: invoiceId);
  Future<void> addPayment(Payment payment) => _add<Payment>('payments', payment, (p) => p.toRealtimeDatabase());
  Future<void> updatePayment(Payment payment) => _update<Payment>('payments', payment, (p) => p.toRealtimeDatabase());
  Future<void> deletePayment(String paymentId) => _delete('payments', paymentId);

  // حساب الرصيد المتبقي للفاتورة
  Future<double> getRemainingBalance(String invoiceId) async {
    Invoice? invoice = await getInvoice(invoiceId);
    if (invoice == null) return 0.0;

    final payments = await _getStream<Payment>('payments', Payment.fromRealtimeDatabase, orderByChild: 'invoiceId', equalTo: invoiceId).first;

    double totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);

    return invoice.total - totalPaid;
  }

  // حساب ملخص المورد
  Future<Map<String, double>> getSupplierSummary(String supplierId) async {
    final invoices = await _getStream<Invoice>('invoices', Invoice.fromRealtimeDatabase, orderByChild: 'supplierId', equalTo: supplierId).first;

    double totalInvoices = 0.0;
    double totalPaid = 0.0;

    for (var invoice in invoices) {
      totalInvoices += invoice.total;
      final payments = await _getStream<Payment>('payments', Payment.fromRealtimeDatabase, orderByChild: 'invoiceId', equalTo: invoice.id).first;
      totalPaid += payments.fold(0.0, (sum, payment) => sum + payment.amount);
    }

    return {
      'totalInvoices': totalInvoices,
      'totalPaid': totalPaid,
      'remainingBalance': totalInvoices - totalPaid,
    };
  }

  Stream<List<dynamic>> getAllMovementsForSupplier(String supplierId) {
    return _getStream<Invoice>('invoices', Invoice.fromRealtimeDatabase, orderByChild: 'supplierId', equalTo: supplierId).asyncMap((invoices) async {
      List<dynamic> movements = [];

      for (var invoice in invoices) {
        movements.add(invoice);
        final payments = await _getStream<Payment>('payments', Payment.fromRealtimeDatabase, orderByChild: 'invoiceId', equalTo: invoice.id).first;
        movements.addAll(payments);
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


