import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/supplier_list_screen.dart';
import 'package:supplier_invoice_app/services/realtime_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة الموردين والفواتير',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SupplierListScreen(),
    );
  }
}