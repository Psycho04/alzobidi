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
import 'pages/products_page.dart';
import 'pages/accounts_page.dart';
import 'pages/invoices_page.dart';
import 'pages/cashbox_page.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_ar.dart';
import 'l10n/app_localizations_en.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(InvoiceItemAdapter());
  Hive.registerAdapter(InvoiceAdapter());

  // Open boxes
  final productsBox = await Hive.openBox<Product>('products');
  final customersBox = await Hive.openBox<Customer>('customers');
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;

  final List<Widget> _pages = [
    const ProductsPage(),
    const AccountsPage(),
    const InvoicesPage(),
    const CashboxPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Animate the FAB when changing pages
    _fabAnimationController.reset();
    _fabAnimationController.forward();
  }

  void _onFabPressed(BuildContext context) {
    switch (_selectedIndex) {
      case 0: // Products page
        _showAddProductDialog(context);
        break;
      case 1: // Accounts page
        _showAddCustomerDialog(context);
        break;
      case 2: // Invoices page
        _showAddInvoiceDialog(context);
        break;
      case 3: // Cashbox page - No add action
        // Refresh cashbox data
        context.read<CashboxCubit>().loadCashboxData();
        break;
    }
  }

  IconData _getFabIcon() {
    switch (_selectedIndex) {
      case 0: // Products page
        return Icons.add_box;
      case 1: // Accounts page
        return Icons.person_add;
      case 2: // Invoices page
        return Icons.receipt_long;
      case 3: // Cashbox page
        return Icons.refresh;
      default:
        return Icons.add;
    }
  }

  String _getFabTooltip() {
    final localizations = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return localizations.addProduct;
      case 1:
        return localizations.addCustomer;
      case 2:
        return localizations.createInvoice;
      case 3:
        return localizations.refreshData;
      default:
        return localizations.add;
    }
  }

  bool _shouldShowFab() {
    // Always show the FAB for all pages
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: _shouldShowFab()
          ? ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabAnimationController,
                curve: Curves.easeInOut,
              ),
              child: FloatingActionButton(
                onPressed: () => _onFabPressed(context),
                tooltip: _getFabTooltip(),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                child: Icon(_getFabIcon()),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onPageChanged,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: AppLocalizations.of(context).productsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: AppLocalizations.of(context).accountsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context).invoicesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: AppLocalizations.of(context).cashboxTab,
          ),
        ],
      ),
    );
  }

  // Dialog methods moved from individual pages to the main screen
  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final localizations = AppLocalizations.of(context);
    String category = '';
    int quantity = 0;
    double pricePerUnit = 0.0;
    DateTime expirationDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(localizations.addProduct),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.categoryType),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterCategory;
                      }
                      return null;
                    },
                    onSaved: (value) => category = value!,
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.quantity),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterQuantity;
                      }
                      final number = int.tryParse(value);
                      if (number == null || number < 0) {
                        return localizations.pleaseEnterValidQuantity;
                      }
                      return null;
                    },
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.pricePerUnit),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterPrice;
                      }
                      final number = double.tryParse(value);
                      if (number == null || number < 0) {
                        return localizations.pleaseEnterValidPrice;
                      }
                      return null;
                    },
                    onSaved: (value) => pricePerUnit = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Get today's date with time set to midnight for proper comparison
                      final today = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );

                      // Set initialDate to today if expirationDate is in the past
                      final initialDate = expirationDate.isBefore(today)
                          ? today
                          : expirationDate;

                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365 * 2)),
                        selectableDayPredicate: (DateTime day) {
                          // Only allow dates from today onwards
                          return !day.isBefore(today);
                        },
                      );
                      if (date != null) {
                        setState(() {
                          expirationDate = date;
                        });
                      }
                    },
                    child: Text(
                        '${localizations.expirationDate}: ${_formatDate(expirationDate)}'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final product = Product(
                      category: category,
                      quantity: quantity,
                      pricePerUnit: pricePerUnit,
                      expirationDate: expirationDate,
                    );
                    context.read<ProductsCubit>().addProduct(product);
                    Navigator.pop(context);
                  }
                },
                child: Text(localizations.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final localizations = AppLocalizations.of(context);
    String name = '';
    String whatsappNumber = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.addCustomer),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration:
                    InputDecoration(labelText: localizations.customerName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterName;
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: localizations.whatsappNumber),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterWhatsapp;
                  }
                  return null;
                },
                onSaved: (value) => whatsappNumber = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final customer = Customer(
                  name: name,
                  whatsappNumber: whatsappNumber,
                );
                context.read<CustomersCubit>().addCustomer(customer);
                Navigator.pop(context);
              }
            },
            child: Text(localizations.add),
          ),
        ],
      ),
    );
  }

  void _showAddInvoiceDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final localizations = AppLocalizations.of(context);
    Customer? selectedCustomer;
    final List<InvoiceItem> items = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.newInvoice),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<CustomersCubit, CustomersState>(
                builder: (context, state) {
                  return DropdownButtonFormField<Customer>(
                    decoration:
                        InputDecoration(labelText: localizations.customer),
                    items: state.customers.map((customer) {
                      return DropdownMenuItem(
                        value: customer,
                        child: Text(customer.name),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return localizations.selectCustomer;
                      }
                      return null;
                    },
                    onChanged: (value) => selectedCustomer = value,
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddProductToInvoiceDialog(context, items),
                child: Text(localizations.addProduct),
              ),
              const SizedBox(height: 16),
              if (items.isNotEmpty) ...[
                Text(localizations.selectedProducts),
                const SizedBox(height: 8),
                ...items.map((item) => ListTile(
                      title: Text(
                        item.product.category,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${localizations.quantity}: ${item.quantity}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${localizations.total}: \$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          items.remove(item);
                          Navigator.pop(context);
                          _showAddInvoiceDialog(context);
                        },
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate() && items.isNotEmpty) {
                final totalAmount = items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.totalPrice,
                );

                final invoice = Invoice(
                  id: context.read<InvoicesCubit>().generateInvoiceId(),
                  customer: selectedCustomer!,
                  items: items,
                  date: DateTime.now(),
                  totalAmount: totalAmount,
                );

                context.read<InvoicesCubit>().addInvoice(invoice);
                Navigator.pop(context);
              }
            },
            child: Text(localizations.createInvoice),
          ),
        ],
      ),
    );
  }

  void _showAddProductToInvoiceDialog(
      BuildContext context, List<InvoiceItem> items) {
    final localizations = AppLocalizations.of(context);
    final Map<Product, int> selectedProducts = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(localizations.selectProducts),
            content: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                final availableProducts = state.products
                    .where((product) => product.quantity > 0)
                    .toList();

                if (availableProducts.isEmpty) {
                  return Text(localizations.noProductsAvailable);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.selectMultipleProducts,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Fixed height container to show only 4 rows
                    SizedBox(
                      height: 280, // Height for approximately 4 product rows
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: availableProducts.map((product) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: selectedProducts
                                            .containsKey(product),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedProducts[product] = 1;
                                            } else {
                                              selectedProducts.remove(product);
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${product.category} (${product.quantity} ${localizations.quantity.toLowerCase()})',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedProducts
                                      .containsKey(product)) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '${localizations.quantity}: ',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        // Use smaller buttons
                                        SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove,
                                                size: 16),
                                            onPressed:
                                                selectedProducts[product]! > 1
                                                    ? () {
                                                        setState(() {
                                                          selectedProducts[
                                                                  product] =
                                                              selectedProducts[
                                                                      product]! -
                                                                  1;
                                                        });
                                                      }
                                                    : null,
                                          ),
                                        ),
                                        Text(
                                          '${selectedProducts[product]}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon:
                                                const Icon(Icons.add, size: 16),
                                            onPressed:
                                                selectedProducts[product]! <
                                                        product.quantity
                                                    ? () {
                                                        setState(() {
                                                          selectedProducts[
                                                                  product] =
                                                              selectedProducts[
                                                                      product]! +
                                                                  1;
                                                        });
                                                      }
                                                    : null,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '\$${(product.pricePerUnit * selectedProducts[product]!).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  if (selectedProducts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.pleaseEnterCategory),
                      ),
                    );
                    return;
                  }

                  // Add all selected products to the invoice
                  selectedProducts.forEach((product, quantity) {
                    final item = InvoiceItem(
                      product: product,
                      quantity: quantity,
                      totalPrice: product.pricePerUnit * quantity,
                    );
                    items.add(item);
                  });

                  Navigator.pop(context);
                },
                child: Text(localizations.addSelected),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
