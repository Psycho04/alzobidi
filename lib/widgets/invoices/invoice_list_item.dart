import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';

class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final Function(BuildContext, Invoice) onShare;
  final Function(BuildContext, Invoice) onDelete;
  final Function(BuildContext, Invoice) onTap;

  const InvoiceListItem({
    super.key,
    required this.invoice,
    required this.onShare,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(invoice.customer.name),
        subtitle: Text('${localizations.date}: ${_formatDate(invoice.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => onShare(context, invoice),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(context, invoice),
            ),
          ],
        ),
        onTap: () => onTap(context, invoice),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
