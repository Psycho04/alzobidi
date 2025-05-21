import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../cubits/customers_cubit.dart';
import '../../cubits/invoices_cubit.dart';
import '../../l10n/app_localizations.dart';
import 'add_product_to_invoice_dialog.dart';
import 'payment_dialog.dart';

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({super.key});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final formKey = GlobalKey<FormState>();
  Customer? selectedCustomer;
  final List<InvoiceItem> items = [];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
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
              onPressed: () => _showAddProductToInvoiceDialog(context),
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
                          '${localizations.total}: SAR ${item.totalPrice.toStringAsFixed(2)}',
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
                        setState(() {
                          items.remove(item);
                        });
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

              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final customersCubit = context.read<CustomersCubit>();

              Navigator.pop(context);

              showPaymentDialog(
                context: context,
                invoice: invoice,
                onPaymentComplete: (amount) {
                  invoice.paidAmount = amount;
                  invoice.isPaid = amount >= invoice.totalAmount;
                  invoice.save();

                  customersCubit.updateCustomerTotalPaid();

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(localizations.paymentSuccessful),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            }
          },
          child: Text(localizations.createInvoice),
        ),
      ],
    );
  }

  void _showAddProductToInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProductToInvoiceDialog(
        onProductsSelected: (selectedProducts) {
          setState(() {
            selectedProducts.forEach((product, quantity) {
              final item = InvoiceItem(
                product: product,
                quantity: quantity,
                totalPrice: product.pricePerUnit * quantity,
              );
              items.add(item);
            });
          });
        },
      ),
    );
  }
}

void showAddInvoiceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AddInvoiceDialog(),
  );
}
