import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product.dart';
import '../../cubits/products_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/invoice.dart';

class AddProductToInvoiceDialog extends StatefulWidget {
  final Function(Map<Product, int>) onProductsSelected;
  final List<InvoiceItem> existingItems;

  const AddProductToInvoiceDialog({
    super.key,
    required this.onProductsSelected,
    required this.existingItems,
  });

  @override
  State<AddProductToInvoiceDialog> createState() =>
      _AddProductToInvoiceDialogState();
}

class _AddProductToInvoiceDialogState extends State<AddProductToInvoiceDialog> {
  final Map<Product, int> selectedProducts = {};

  @override
  void initState() {
    super.initState();
    // Initialize selectedProducts with existing items
    for (var item in widget.existingItems) {
      selectedProducts[item.product] = item.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.selectProducts),
      content: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          final availableProducts = state.products
              .where((product) => product.quantity > 0)
              .toList();

          if (availableProducts.isEmpty) {
            return Text(localizations.noProductsAvailable);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.selectMultipleProducts,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Fixed height container to show only 4 rows
              SizedBox(
                height: 280, // Height for approximately 4 product rows
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: availableProducts.map((product) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: selectedProducts
                                      .containsKey(product),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedProducts[product] = 1;
                                      } else {
                                        selectedProducts.remove(product);
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    '${product.category} (${product.quantity} ${localizations.quantity.toLowerCase()})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (selectedProducts
                                .containsKey(product)) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${localizations.quantity}: ',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  // Use smaller buttons
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove,
                                          size: 16),
                                      onPressed:
                                          selectedProducts[product]! > 1
                                              ? () {
                                                  setState(() {
                                                    selectedProducts[
                                                            product] =
                                                        selectedProducts[
                                                                product]! -
                                                            1;
                                                  });
                                                }
                                              : null,
                                    ),
                                  ),
                                  Text(
                                    '${selectedProducts[product]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon:
                                          const Icon(Icons.add, size: 16),
                                      onPressed:
                                          selectedProducts[product]! <
                                                  product.quantity
                                              ? () {
                                                  setState(() {
                                                    selectedProducts[
                                                            product] =
                                                        selectedProducts[
                                                                product]! +
                                                            1;
                                                  });
                                                }
                                              : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'SAR ${(product.pricePerUnit * selectedProducts[product]!).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () {
            if (selectedProducts.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.pleaseEnterCategory),
                ),
              );
              return;
            }

            widget.onProductsSelected(selectedProducts);
            Navigator.pop(context);
          },
          child: Text(localizations.addSelected),
        ),
      ],
    );
  }
}
