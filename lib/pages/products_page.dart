import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/products_cubit.dart';
import '../models/product.dart';
import '../l10n/app_localizations.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isLowStockExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).productsTab),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.lowStockProducts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).lowStock,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      if (state.lowStockProducts.length >
                          4) // Only show expand button if more than 4 products
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLowStockExpanded = !_isLowStockExpanded;
                            });
                          },
                          icon: Icon(
                            _isLowStockExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          ),
                          label: Text(
                            _isLowStockExpanded
                                ? AppLocalizations.of(context).close
                                : AppLocalizations.of(context).showAll,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildLimitedProductGrid(
                      context, state.lowStockProducts, _isLowStockExpanded),
                  const SizedBox(height: 24),
                ],
                if (state.expiringSoonProducts.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context).expiringSoon,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProductGrid(context, state.expiringSoonProducts),
                  const SizedBox(height: 24),
                ],
                Text(
                  AppLocalizations.of(context).allProducts,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProductGrid(context, state.products),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLimitedProductGrid(
      BuildContext context, List<Product> products, bool showAll) {
    // If not expanded, limit to 4 products (2 rows of 2 products each)
    final displayProducts = showAll ? products : products.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2, // Reduced to give more height to each card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return Card(
          child: InkWell(
            onTap: () => _showEditProductDialog(context, product),
            child: Padding(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum space needed
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                  const Spacer(),
                  // Use more compact layout for details
                  Text(
                    '${AppLocalizations.of(context).quantity}: ${product.quantity}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${AppLocalizations.of(context).price}: \$${product.pricePerUnit.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Make sure the date fits
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${AppLocalizations.of(context).expires}: ${_formatDate(product.expirationDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.isExpiringSoon ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2, // Reduced to give more height to each card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: InkWell(
            onTap: () => _showEditProductDialog(context, product),
            child: Padding(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum space needed
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                  const Spacer(),
                  // Use more compact layout for details
                  Text(
                    '${AppLocalizations.of(context).quantity}: ${product.quantity}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${AppLocalizations.of(context).price}: \$${product.pricePerUnit.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Make sure the date fits
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${AppLocalizations.of(context).expires}: ${_formatDate(product.expirationDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.isExpiringSoon ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    String category = product.category;
    int quantity = product.quantity;
    double pricePerUnit = product.pricePerUnit;
    DateTime expirationDate = product.expirationDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final localizations = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(localizations.editProduct),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.categoryType),
                    initialValue: category,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterCategory;
                      }
                      return null;
                    },
                    onSaved: (value) => category = value!,
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.quantity),
                    initialValue: quantity.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterQuantity;
                      }
                      final number = int.tryParse(value);
                      if (number == null || number < 0) {
                        return localizations.pleaseEnterValidQuantity;
                      }
                      return null;
                    },
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: localizations.pricePerUnit),
                    initialValue: pricePerUnit.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterPrice;
                      }
                      final number = double.tryParse(value);
                      if (number == null || number < 0) {
                        return localizations.pleaseEnterValidPrice;
                      }
                      return null;
                    },
                    onSaved: (value) => pricePerUnit = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Get today's date with time set to midnight for proper comparison
                      final today = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );

                      // Set initialDate to today if expirationDate is in the past
                      final initialDate = expirationDate.isBefore(today)
                          ? today
                          : expirationDate;

                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365 * 2)),
                        selectableDayPredicate: (DateTime day) {
                          // Only allow dates from today onwards
                          return !day.isBefore(today);
                        },
                      );
                      if (date != null) {
                        setState(() {
                          expirationDate = date;
                        });
                      }
                    },
                    child: Text(
                        '${localizations.expirationDate}: ${_formatDate(expirationDate)}'),
                  ),
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    product.category = category;
                    product.quantity = quantity;
                    product.pricePerUnit = pricePerUnit;
                    product.expirationDate = expirationDate;
                    context.read<ProductsCubit>().updateProduct(product);
                    Navigator.pop(context);
                  }
                },
                child: Text(localizations.save),
              ),
              TextButton(
                onPressed: () {
                  context.read<ProductsCubit>().deleteProduct(product);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(localizations.delete),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
