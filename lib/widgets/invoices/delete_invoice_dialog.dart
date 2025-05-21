import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/invoice.dart';
import '../../cubits/invoices_cubit.dart';
import '../../cubits/cashbox_cubit.dart';
import '../../l10n/app_localizations.dart';

class DeleteInvoiceDialog extends StatelessWidget {
  final Invoice invoice;

  const DeleteInvoiceDialog({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(localizations.delete),
      content: Text('${localizations.delete} ${localizations.invoices} #${invoice.id}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => _deleteInvoice(context),
          child: Text(localizations.delete),
        ),
      ],
    );
  }

  Future<void> _deleteInvoice(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
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
            content: Text('${localizations.invoices} #${invoice.id} ${localizations.delete}'),
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
            content: Text('${localizations.delete} ${localizations.invoices} - Error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );

        // Still try to update the UI
        context.read<InvoicesCubit>().loadInvoices();
        context.read<CashboxCubit>().updateCashbox();
      }
    }
  }
}

void showDeleteInvoiceDialog(BuildContext context, Invoice invoice) {
  showDialog(
    context: context,
    builder: (context) => DeleteInvoiceDialog(invoice: invoice),
  );
}
