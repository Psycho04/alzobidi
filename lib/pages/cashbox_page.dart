import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/cashbox_cubit.dart';
import '../models/invoice.dart';
import 'package:hive/hive.dart';
import '../l10n/app_localizations.dart';

class CashboxPage extends StatefulWidget {
  const CashboxPage({super.key});

  @override
  State<CashboxPage> createState() => _CashboxPageState();
}

class _CashboxPageState extends State<CashboxPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshAnimationController;
  final Map<String, double> _previousValues = {
    'sales': 0.0,
    'purchases': 0.0,
    'profit': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _checkForUpdates(CashboxState state) {
    bool hasUpdates = false;

    if (_previousValues['sales'] != state.totalSales) {
      _previousValues['sales'] = state.totalSales;
      hasUpdates = true;
    }

    if (_previousValues['purchases'] != state.totalPurchases) {
      _previousValues['purchases'] = state.totalPurchases;
      hasUpdates = true;
    }

    if (_previousValues['profit'] != state.totalProfit) {
      _previousValues['profit'] = state.totalProfit;
      hasUpdates = true;
    }

    if (hasUpdates) {
      _refreshAnimationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cashboxTab),
        actions: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0)
                .animate(_refreshAnimationController),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context).refreshData,
              onPressed: () {
                context.read<CashboxCubit>().loadCashboxData();
                _refreshAnimationController.forward(from: 0.0);
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<CashboxCubit, CashboxState>(
        listener: (context, state) {
          _checkForUpdates(state);
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).financialSummary,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).lastUpdated}: ${DateFormat('yyyy/MM/dd - HH:mm').format(DateTime.now())}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary cards
                  _buildSummaryCard(
                    context,
                    AppLocalizations.of(context).sales,
                    state.totalSales,
                    Colors.green,
                    Icons.trending_up,
                    const [Color(0xFF43A047), Color(0xFF2E7D32)],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    AppLocalizations.of(context).purchases,
                    state.totalPurchases,
                    Colors.orange,
                    Icons.shopping_cart,
                    const [Color(0xFFFB8C00), Color(0xFFEF6C00)],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    AppLocalizations.of(context).totalProfit,
                    state.totalProfit,
                    state.totalProfit >= 0 ? Colors.green : Colors.red,
                    state.totalProfit >= 0
                        ? Icons.attach_money
                        : Icons.money_off,
                    state.totalProfit >= 0
                        ? const [Color(0xFF43A047), Color(0xFF2E7D32)]
                        : const [Color(0xFFE53935), Color(0xFFC62828)],
                  ),

                  const SizedBox(height: 24),

                  // Recent transactions section
                  Text(
                    AppLocalizations.of(context).recentTransactions,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentTransactions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color textColor,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withAlpha(50),
              gradientColors[1].withAlpha(25),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gradientColors[0].withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: gradientColors[1],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: amount),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Text(
                          '${value.toStringAsFixed(2)} \$',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    // Use BlocBuilder to rebuild when cashbox state changes
    return BlocBuilder<CashboxCubit, CashboxState>(
      builder: (context, state) {
        final invoicesBox = Hive.box<Invoice>('invoices');
        final recentInvoices = invoicesBox.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        if (recentInvoices.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(AppLocalizations.of(context).noRecentTransactions),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentInvoices.length > 5 ? 5 : recentInvoices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final invoice = recentInvoices[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(25),
                  child: const Icon(Icons.receipt),
                ),
                title: Text(invoice.customer.name),
                subtitle: Text(DateFormat('yyyy/MM/dd').format(invoice.date)),
                trailing: Text(
                  '${invoice.totalAmount.toStringAsFixed(2)} \$',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
