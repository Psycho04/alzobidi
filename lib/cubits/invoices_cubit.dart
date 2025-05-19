import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import 'cashbox_cubit.dart';
import 'products_cubit.dart';
import 'customers_cubit.dart';

// Events
abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object> get props => [];
}

class LoadInvoices extends InvoicesEvent {}

class AddInvoice extends InvoicesEvent {
  final Invoice invoice;

  const AddInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class DeleteInvoice extends InvoicesEvent {
  final Invoice invoice;

  const DeleteInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

// State
class InvoicesState extends Equatable {
  final List<Invoice> invoices;
  final Map<String, List<Invoice>> customerInvoices;

  const InvoicesState({
    this.invoices = const [],
    this.customerInvoices = const {},
  });

  InvoicesState copyWith({
    List<Invoice>? invoices,
    Map<String, List<Invoice>>? customerInvoices,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      customerInvoices: customerInvoices ?? this.customerInvoices,
    );
  }

  @override
  List<Object> get props => [invoices, customerInvoices];
}

// Cubit
class InvoicesCubit extends Cubit<InvoicesState> {
  final Box<Invoice> _invoicesBox;
  final Box<Product> _productsBox;
  CashboxCubit? _cashboxCubit;
  ProductsCubit? _productsCubit;
  CustomersCubit? _customersCubit;

  InvoicesCubit(this._invoicesBox, this._productsBox)
      : super(const InvoicesState()) {
    loadInvoices();
  }

  // Set the cashbox cubit reference
  void setCashboxCubit(CashboxCubit cashboxCubit) {
    _cashboxCubit = cashboxCubit;
  }

  // Set the products cubit reference
  void setProductsCubit(ProductsCubit productsCubit) {
    _productsCubit = productsCubit;
  }

  // Set the customers cubit reference
  void setCustomersCubit(CustomersCubit customersCubit) {
    _customersCubit = customersCubit;
  }

  void loadInvoices() {
    final invoices = _invoicesBox.values.toList();
    final customerInvoices = <String, List<Invoice>>{};

    for (final invoice in invoices) {
      customerInvoices
          .putIfAbsent(invoice.customer.name, () => [])
          .add(invoice);
    }

    emit(InvoicesState(
      invoices: invoices,
      customerInvoices: customerInvoices,
    ));
  }

  Future<void> addInvoice(Invoice invoice) async {
    // Update product quantities
    for (final item in invoice.items) {
      final product = item.product;
      product.quantity -= item.quantity;
      await product.save();
    }

    await _invoicesBox.add(invoice);
    loadInvoices();

    // Update cashbox data
    _cashboxCubit?.updateCashbox();

    // Update products data
    _productsCubit?.updateProducts();

    // Update customer total paid
    _customersCubit?.updateCustomerTotalPaid();
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    try {
      // Restore product quantities - need to find the actual product in the box
      for (final item in invoice.items) {
        // Get the product from the box by its key to ensure it's a valid box object
        final productInBox = _productsBox.values.firstWhere(
          (p) => p.category == item.product.category,
          orElse: () => item.product,
        );

        // Update the quantity
        productInBox.quantity += item.quantity;

        // Only save if the product is in a box
        if (productInBox.isInBox) {
          await productInBox.save();
        }
      }

      // Delete the invoice if it's in a box
      if (invoice.isInBox) {
        await invoice.delete();
      }

      // Reload invoices to update the UI
      loadInvoices();

      // Update cashbox data immediately
      if (_cashboxCubit != null) {
        _cashboxCubit!.loadCashboxData();
      }

      // Update products data
      if (_productsCubit != null) {
        _productsCubit!.loadProducts();
      }

      // Update customer total paid
      if (_customersCubit != null) {
        _customersCubit!.updateCustomerTotalPaid();
      }
    } catch (e) {
      // Error handling without print
      // Continue with updates even if there was an error
      loadInvoices();
      _cashboxCubit?.loadCashboxData();
      _productsCubit?.loadProducts();
      _customersCubit?.updateCustomerTotalPaid();
    }
  }

  String generateInvoiceId() {
    return const Uuid().v4();
  }
}
