import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/products_cubit.dart';
import '../models/product.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dialogs/edit_product_dialog.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isLowStockExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).productsTab),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchProducts,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (query) {
                      context.read<ProductsCubit>().searchProducts(query);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (state.searchQuery.isEmpty) ...[
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
                          if (state.lowStockProducts.length > 4)
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
                  ] else ...[
                    Text(
                      AppLocalizations.of(context).searchResults,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProductGrid(context, state.filteredProducts),
                  ],
                ],
              ),
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
                    '${AppLocalizations.of(context).price}: SAR ${product.pricePerUnit.toStringAsFixed(2)}',
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
                    '${AppLocalizations.of(context).price}: SAR ${product.pricePerUnit.toStringAsFixed(2)}',
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
    showEditProductDialog(context, product);
  }

  String _formatDate(DateTime date) {
    // Format as dd/mm/yyyy
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}
