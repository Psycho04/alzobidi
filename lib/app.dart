import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/product.dart';
import 'models/customer.dart';
import 'models/invoice.dart';
import 'cubits/products_cubit.dart';
import 'cubits/customers_cubit.dart';
import 'cubits/invoices_cubit.dart';
import 'cubits/cashbox_cubit.dart';
import 'screens/main_screen.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  final Box<Product> productsBox;
  final Box<Customer> customersBox;
  final Box<Invoice> invoicesBox;

  const MyApp({
    super.key,
    required this.productsBox,
    required this.customersBox,
    required this.invoicesBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductsCubit(productsBox)),
        BlocProvider(create: (context) => CustomersCubit(customersBox)),
        BlocProvider(
            create: (context) => InvoicesCubit(invoicesBox, productsBox)),
        BlocProvider(
            create: (context) => CashboxCubit(invoicesBox, productsBox)),
      ],
      child: Builder(builder: (context) {
        // Connect cubits for real-time updates
        final invoicesCubit = context.read<InvoicesCubit>();
        final cashboxCubit = context.read<CashboxCubit>();
        final productsCubit = context.read<ProductsCubit>();
        final customersCubit = context.read<CustomersCubit>();

        // Set up connections between cubits
        invoicesCubit.setCashboxCubit(cashboxCubit);
        invoicesCubit.setProductsCubit(productsCubit);
        invoicesCubit.setCustomersCubit(customersCubit);
        productsCubit.setCashboxCubit(cashboxCubit);

        // Connect customers cubit to invoices box for total paid calculation
        customersCubit.setInvoicesBox(invoicesBox);

        // Connect customers cubit to invoices cubit for deleting invoices
        customersCubit.setInvoicesCubit(invoicesCubit);

        // Initialize customer total paid calculations
        customersCubit.updateCustomerTotalPaid();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'عيادة الزبيدي البيطرية', // Default title in Arabic
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B4513), // Brownish theme
              primary: const Color(0xFF8B4513),
              secondary: const Color(0xFFD2691E),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
            useMaterial3: true,
          ),
          locale: const Locale('ar'), // Set Arabic as default language
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
          builder: (context, child) {
            // This ensures RTL for Arabic
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );
      }),
    );
  }
}
