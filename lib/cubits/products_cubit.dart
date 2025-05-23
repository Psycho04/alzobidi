import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';
import 'cashbox_cubit.dart';

// Events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductsEvent {}

class AddProduct extends ProductsEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final Product product;

  const DeleteProduct(this.product);

  @override
  List<Object> get props => [product];
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

// State
class ProductsState extends Equatable {
  final List<Product> products;
  final List<Product> lowStockProducts;
  final List<Product> expiringSoonProducts;
  final List<Product> outOfStockProducts;
  final String searchQuery;
  final List<Product> filteredProducts;

  const ProductsState({
    this.products = const [],
    this.lowStockProducts = const [],
    this.expiringSoonProducts = const [],
    this.outOfStockProducts = const [],
    this.searchQuery = '',
    this.filteredProducts = const [],
  });

  ProductsState copyWith({
    List<Product>? products,
    List<Product>? lowStockProducts,
    List<Product>? expiringSoonProducts,
    List<Product>? outOfStockProducts,
    String? searchQuery,
    List<Product>? filteredProducts,
  }) {
    return ProductsState(
      products: products ?? this.products,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      expiringSoonProducts: expiringSoonProducts ?? this.expiringSoonProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }

  @override
  List<Object> get props => [
        products,
        lowStockProducts,
        expiringSoonProducts,
        outOfStockProducts,
        searchQuery,
        filteredProducts,
      ];
}

// Cubit
class ProductsCubit extends Cubit<ProductsState> {
  final Box<Product> _productsBox;
  CashboxCubit? _cashboxCubit;

  ProductsCubit(this._productsBox) : super(const ProductsState()) {
    loadProducts();
  }

  // Set the cashbox cubit reference
  void setCashboxCubit(CashboxCubit cashboxCubit) {
    _cashboxCubit = cashboxCubit;
  }

  void loadProducts() {
    final products = _productsBox.values.toList();
    final lowStock = products.where((p) => p.isLowStock).toList();
    final expiringSoon = products.where((p) => p.isExpiringSoon).toList();
    final outOfStock = products.where((p) => p.quantity == 0).toList();

    emit(ProductsState(
      products: products,
      lowStockProducts: lowStock,
      expiringSoonProducts: expiringSoon,
      outOfStockProducts: outOfStock,
      filteredProducts: products,
    ));
  }

  // Method to update products data when products are modified elsewhere
  void updateProducts() {
    loadProducts();
  }

  Future<void> addProduct(Product product) async {
    await _productsBox.add(product);
    loadProducts();
    // Update cashbox when adding a product
    _cashboxCubit?.updateCashbox();
  }

  Future<void> updateProduct(Product product) async {
    await product.save();
    loadProducts();
    // Update cashbox when updating a product
    _cashboxCubit?.updateCashbox();
  }

  Future<void> deleteProduct(Product product) async {
    await product.delete();
    loadProducts();
    // Update cashbox when deleting a product
    _cashboxCubit?.updateCashbox();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredProducts: state.products,
      ));
      return;
    }

    final filtered = state.products.where((product) {
      return product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredProducts: filtered,
    ));
  }
}
