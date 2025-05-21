import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';

class CustomerInvoicesTile extends StatelessWidget {
  final String customerName;
  final List<Invoice> invoices;
  final Function(BuildContext, Invoice) onDelete;
  final Function(BuildContext, Invoice) onTap;

  const CustomerInvoicesTile({
    super.key,
    required this.customerName,
    required this.invoices,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      child: ExpansionTile(
        title: Text(customerName),
        subtitle: Text('${invoices.length} ${localizations.invoices}'),
        children: invoices.map((invoice) {
          return ListTile(
            title: Text('${localizations.date}: ${_formatDate(invoice.date)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(context, invoice),
                ),
              ],
            ),
            onTap: () => onTap(context, invoice),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
