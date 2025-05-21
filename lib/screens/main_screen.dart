import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/cashbox_cubit.dart';
import '../pages/products_page.dart';
import '../pages/accounts_page.dart';
import '../pages/invoices_page.dart';
import '../pages/cashbox_page.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dialogs/dialogs.dart';

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
        showAddProductDialog(context);
        break;
      case 1: // Accounts page
        showAddCustomerDialog(context);
        break;
      case 2: // Invoices page
        showAddInvoiceDialog(context);
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
}
