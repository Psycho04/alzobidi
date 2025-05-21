import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';

class InvoiceDetailsDialog extends StatelessWidget {
  final Invoice invoice;
  final Function(BuildContext, Invoice) onShare;
  final Function(BuildContext, Invoice) onDelete;

  const InvoiceDetailsDialog({
    super.key,
    required this.invoice,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AlertDialog(
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
                      Text('${item.quantity} x SAR ${item.product.pricePerUnit.toStringAsFixed(2)}'),
                      Text('SAR ${item.totalPrice.toStringAsFixed(2)}'),
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
                  'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
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
          onPressed: () => onShare(context, invoice),
          child: Text(localizations.share),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            onDelete(context, invoice);
          },
          child: Text(localizations.delete),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

void showInvoiceDetailsDialog({
  required BuildContext context,
  required Invoice invoice,
  required Function(BuildContext, Invoice) onShare,
  required Function(BuildContext, Invoice) onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) => InvoiceDetailsDialog(
      invoice: invoice,
      onShare: onShare,
      onDelete: onDelete,
    ),
  );
}
