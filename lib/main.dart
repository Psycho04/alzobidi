import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/customer.dart';
import 'models/invoice.dart';
import 'l10n/app_localizations_ar.dart';
import 'l10n/app_localizations_en.dart';
import 'app.dart';
// import 'package:your_app_name/models/customer.g.dart';
// import 'package:your_app_name/models/invoice.g.dart';
// import 'package:your_app_name/cubits/customers_cubit.dart';
// import 'package:your_app_name/cubits/invoices_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(InvoiceItemAdapter());
  Hive.registerAdapter(InvoiceAdapter());

  // Open boxes
  final Box<Product> productsBox = await Hive.openBox<Product>('products');
  final Box<Customer> customersBox = await Hive.openBox<Customer>('customers');
  final invoicesBox = await Hive.openBox<Invoice>('invoices');

  // Initialize localization classes to avoid null errors
  AppLocalizationsAr();
  AppLocalizationsEn();

  runApp(MyApp(
    productsBox: productsBox,
    customersBox: customersBox,
    invoicesBox: invoicesBox,
  ));
}
