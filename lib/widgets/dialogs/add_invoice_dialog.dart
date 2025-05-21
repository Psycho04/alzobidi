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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F3EF), // Light beige background
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.newInvoice,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<CustomersCubit, CustomersState>(
                    builder: (context, state) {
                      return DropdownButtonFormField<Customer>(
                        decoration: InputDecoration(
                          labelText: localizations.customer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB87C5E), // A slightly different shade for variation
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    child: Text(localizations.addProduct),
                  ),
                  const SizedBox(height: 16),
                  if (items.isNotEmpty) ...[
                    Text(localizations.selectedProducts),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250.0, // Approximate height for 5 items
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
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
                                  items.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: Text(localizations.cancel),
                ),
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 172, 113, 83), // Match add product button color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                  ),
                  child: Text(localizations.createInvoice),
                ),
              ],
            ),
          ],
        ),
      ),
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
              final existingItemIndex = items.indexWhere((i) => i.product.category == product.category);
              if (existingItemIndex != -1) {
                items[existingItemIndex] = item;
              } else {
                items.add(item);
              }
            });
          });
        },
        existingItems: items,
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
