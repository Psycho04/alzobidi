import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/invoices_cubit.dart';
import '../models/invoice.dart';
import '../l10n/app_localizations.dart';
import '../widgets/invoices/invoices.dart';
import 'package:pdf/pdf.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.invoices),
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.allInvoices),
              Tab(text: localizations.customerInvoices),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllInvoicesTab(context),
            _buildCustomerInvoicesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAllInvoicesTab(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.invoices.length,
          itemBuilder: (context, index) {
            final invoice = state.invoices[index];
            return InvoiceListItem(
              invoice: invoice,
              onShare: _shareInvoice,
              onDelete: _confirmDeleteInvoice,
              onTap: _showInvoiceDetails,
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerInvoicesTab(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.customerInvoices.length,
          itemBuilder: (context, index) {
            final customerName = state.customerInvoices.keys.elementAt(index);
            final invoices = state.customerInvoices[customerName]!;
            return CustomerInvoicesTile(
              customerName: customerName,
              invoices: invoices,
              onDelete: _confirmDeleteInvoice,
              onTap: _showInvoiceDetails,
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showInvoiceDetailsDialog(
      context: context,
      invoice: invoice,
      onShare: _shareInvoice,
      onDelete: _confirmDeleteInvoice,
    );
  }

  Future<void> _shareInvoice(BuildContext context, Invoice invoice) async {
    await PdfInvoiceGenerator.generateAndShareInvoice(context, invoice);
  }

  void _confirmDeleteInvoice(BuildContext context, Invoice invoice) {
    showDeleteInvoiceDialog(context, invoice);
  }
}
