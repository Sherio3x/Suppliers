import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // خدمات الموردين
  Stream<List<Supplier>> getSuppliers() {
    return _db.collection('suppliers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList());
  }

  Future<void> addSupplier(Supplier supplier) {
    return _db.collection('suppliers').add(supplier.toFirestore());
  }

  Future<void> updateSupplier(Supplier supplier) {
    return _db.collection('suppliers').doc(supplier.id).update(supplier.toFirestore());
  }

  Future<void> deleteSupplier(String supplierId) {
    return _db.collection('suppliers').doc(supplierId).delete();
  }

  Future<Supplier?> getSupplier(String supplierId) async {
    DocumentSnapshot doc = await _db.collection('suppliers').doc(supplierId).get();
    if (doc.exists) {
      return Supplier.fromFirestore(doc);
    }
    return null;
  }

  // خدمات الفواتير
  Stream<List<Invoice>> getInvoices() {
    return _db.collection('invoices').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList());
  }

  Stream<List<Invoice>> getInvoicesBySupplier(String supplierId) {
    return _db.collection('invoices')
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList());
  }

  Future<void> addInvoice(Invoice invoice) {
    return _db.collection('invoices').add(invoice.toFirestore());
  }

  Future<void> updateInvoice(Invoice invoice) {
    return _db.collection('invoices').doc(invoice.id).update(invoice.toFirestore());
  }

  Future<void> deleteInvoice(String invoiceId) {
    return _db.collection('invoices').doc(invoiceId).delete();
  }

  Future<Invoice?> getInvoice(String invoiceId) async {
    DocumentSnapshot doc = await _db.collection('invoices').doc(invoiceId).get();
    if (doc.exists) {
      return Invoice.fromFirestore(doc);
    }
    return null;
  }

  // خدمات المدفوعات
  Stream<List<Payment>> getPaymentsByInvoice(String invoiceId) {
    return _db.collection('payments')
        .where('invoiceId', isEqualTo: invoiceId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  Future<void> addPayment(Payment payment) {
    return _db.collection('payments').add(payment.toFirestore());
  }

  Future<void> updatePayment(Payment payment) {
    return _db.collection('payments').doc(payment.id).update(payment.toFirestore());
  }

  Future<void> deletePayment(String paymentId) {
    return _db.collection('payments').doc(paymentId).delete();
  }

  // حساب الرصيد المتبقي للفاتورة
  Future<double> getRemainingBalance(String invoiceId) async {
    Invoice? invoice = await getInvoice(invoiceId);
    if (invoice == null) return 0.0;

    QuerySnapshot paymentsSnapshot = await _db.collection('payments')
        .where('invoiceId', isEqualTo: invoiceId)
        .get();

    double totalPaid = 0.0;
    for (var doc in paymentsSnapshot.docs) {
      Payment payment = Payment.fromFirestore(doc);
      totalPaid += payment.amount;
    }

    return invoice.total - totalPaid;
  }

  // حساب ملخص المورد
  Future<Map<String, double>> getSupplierSummary(String supplierId) async {
    QuerySnapshot invoicesSnapshot = await _db.collection('invoices')
        .where('supplierId', isEqualTo: supplierId)
        .get();

    double totalInvoices = 0.0;
    double totalPaid = 0.0;

    for (var doc in invoicesSnapshot.docs) {
      Invoice invoice = Invoice.fromFirestore(doc);
      totalInvoices += invoice.total;

      QuerySnapshot paymentsSnapshot = await _db.collection('payments')
          .where('invoiceId', isEqualTo: invoice.id)
          .get();

      for (var paymentDoc in paymentsSnapshot.docs) {
        Payment payment = Payment.fromFirestore(paymentDoc);
        totalPaid += payment.amount;
      }
    }

    return {
      'totalInvoices': totalInvoices,
      'totalPaid': totalPaid,
      'remainingBalance': totalInvoices - totalPaid,
    };
  }
}



  Stream<List<dynamic>> getAllMovementsForSupplier(String supplierId) {
    return _db.collection("invoices")
        .where("supplierId", isEqualTo: supplierId)
        .snapshots()
        .asyncMap((invoiceSnapshot) async {
      List<dynamic> movements = [];
      for (var invoiceDoc in invoiceSnapshot.docs) {
        Invoice invoice = Invoice.fromFirestore(invoiceDoc);
        movements.add(invoice);

        QuerySnapshot paymentsSnapshot = await _db.collection("payments")
            .where("invoiceId", isEqualTo: invoice.id)
            .get();
        for (var paymentDoc in paymentsSnapshot.docs) {
          Payment payment = Payment.fromFirestore(paymentDoc);
          movements.add(payment);
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


