import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../cubits/invoices_cubit.dart';
import '../cubits/cashbox_cubit.dart';
import '../models/invoice.dart';
import '../l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.invoices.length,
          itemBuilder: (context, index) {
            final invoice = state.invoices[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(invoice.customer.name),
                subtitle:
                    Text('${localizations.date}: ${_formatDate(invoice.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareInvoice(context, invoice),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteInvoice(context, invoice),
                    ),
                  ],
                ),
                onTap: () => _showInvoiceDetails(context, invoice),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerInvoicesTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.customerInvoices.length,
          itemBuilder: (context, index) {
            final customerName = state.customerInvoices.keys.elementAt(index);
            final invoices = state.customerInvoices[customerName]!;
            return Card(
              child: ExpansionTile(
                title: Text(customerName),
                subtitle: Text('${invoices.length} ${localizations.invoices}'),
                children: invoices.map((invoice) {
                  return ListTile(
                    title: Text(
                        '${localizations.date}: ${_formatDate(invoice.date)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDeleteInvoice(context, invoice),
                        ),
                      ],
                    ),
                    onTap: () => _showInvoiceDetails(context, invoice),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${localizations.invoices} #${invoice.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${localizations.customer}: ${invoice.customer.name}'),
              Text('${localizations.date}: ${_formatDate(invoice.date)}'),
              const SizedBox(height: 16),
              Text(
                '${localizations.items}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.product.category),
                        ),
                        Text(
                            '${item.quantity} x \$${item.product.pricePerUnit.toStringAsFixed(2)}'),
                        Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${localizations.total}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
          TextButton(
            onPressed: () => _shareInvoice(context, invoice),
            child: Text(localizations.share),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteInvoice(context, invoice);
            },
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context, Invoice invoice) async {
    final localizations = AppLocalizations.of(context);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // Set RTL for Arabic text
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                localizations.institutionName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('${localizations.taxNumber}: ${Invoice.taxNumber}'),
              pw.Text(
                  '${localizations.commercialRegistration}: ${Invoice.commercialRegistrationNumber}'),
              pw.SizedBox(height: 16),
              pw.Text('${localizations.invoices} #${invoice.id}'),
              pw.Text('${localizations.date}: ${_formatDate(invoice.date)}'),
              pw.Text('${localizations.customer}: ${invoice.customer.name}'),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(localizations.product),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(localizations.quantity),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(localizations.price),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(localizations.total),
                      ),
                    ],
                  ),
                  ...invoice.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.product.category),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '\$${item.product.pricePerUnit.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '${localizations.total}: \$${invoice.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${localizations.invoices} #${invoice.id}',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDeleteInvoice(BuildContext context, Invoice invoice) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.delete),
        content: Text(
            '${localizations.delete} ${localizations.invoices} #${invoice.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                // Show a loading indicator while deleting
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Delete the invoice
                await context.read<InvoicesCubit>().deleteInvoice(invoice);

                // Close both dialogs
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  Navigator.pop(context); // Close confirmation dialog

                  // Explicitly update the cashbox
                  context.read<CashboxCubit>().updateCashbox();

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${localizations.invoices} #${invoice.id} ${localizations.delete}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Handle any errors
                if (context.mounted) {
                  // Close the loading dialog if it's still showing
                  Navigator.pop(context);
                  Navigator.pop(context); // Close confirmation dialog

                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${localizations.delete} ${localizations.invoices} - Error'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Still try to update the UI
                  context.read<InvoicesCubit>().loadInvoices();
                  context.read<CashboxCubit>().updateCashbox();
                }
              }
            },
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}
