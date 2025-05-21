import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/invoice.dart';

// Events
abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomers extends CustomersEvent {}

class AddCustomer extends CustomersEvent {
  final Customer customer;

  const AddCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class UpdateCustomer extends CustomersEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class DeleteCustomer extends CustomersEvent {
  final Customer customer;

  const DeleteCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

// State
class CustomersState extends Equatable {
  final List<Customer> customers;

  const CustomersState({
    this.customers = const [],
  });

  CustomersState copyWith({
    List<Customer>? customers,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
    );
  }

  @override
  List<Object> get props => [customers];
}

// Cubit
class CustomersCubit extends Cubit<CustomersState> {
  final Box<Customer> _customersBox;
  Box<Invoice>? _invoicesBox;
  dynamic _invoicesCubit; // Using dynamic to avoid circular dependency

  CustomersCubit(this._customersBox) : super(const CustomersState()) {
    loadCustomers();
  }

  // Set the invoices box reference to calculate total paid
  void setInvoicesBox(Box<Invoice> invoicesBox) {
    _invoicesBox = invoicesBox;
    updateCustomerTotalPaid();
  }

  // Set the invoices cubit reference
  void setInvoicesCubit(dynamic invoicesCubit) {
    _invoicesCubit = invoicesCubit;
  }

  void loadCustomers() {
    final customers = _customersBox.values.toList();
    customers.sort((a, b) => a.name.compareTo(b.name));
    emit(CustomersState(customers: customers));
  }

  Future<void> addCustomer(Customer customer) async {
    await _customersBox.add(customer);
    loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await customer.save();
    loadCustomers();
  }

  Future<void> deleteCustomer(Customer customer) async {
    if (_invoicesBox != null && _invoicesCubit != null) {
      // Find all invoices associated with this customer
      final customerInvoices = _invoicesBox!.values
          .where((invoice) => invoice.customer.name == customer.name)
          .toList();

      // Delete each invoice
      for (final invoice in customerInvoices) {
        await _invoicesCubit.deleteInvoice(invoice);
      }
    }

    // Delete the customer
    await customer.delete();
    loadCustomers();
  }

  // Calculate and update the total paid and remaining balance for each customer based on their invoices
  void updateCustomerTotalPaid() {
    if (_invoicesBox == null) return;

    final invoices = _invoicesBox!.values.toList();
    final customerTotalInvoiceAmountMap = <String, double>{};
    final customerTotalPaidAmountMap = <String, double>{};

    // Calculate total invoice amount and total paid amount for each customer
    for (final invoice in invoices) {
      final customerName = invoice.customer.name;

      // Sum total invoice amount
      customerTotalInvoiceAmountMap[customerName] =
          (customerTotalInvoiceAmountMap[customerName] ?? 0.0) + invoice.totalAmount;

      // Sum total paid amount
      customerTotalPaidAmountMap[customerName] =
          (customerTotalPaidAmountMap[customerName] ?? 0.0) + (invoice.paidAmount ?? 0.0);
    }

    // Update customer objects
    for (final customer in _customersBox.values) {
      final totalInvoiceAmount = customerTotalInvoiceAmountMap[customer.name] ?? 0.0;
      final totalPaidAmount = customerTotalPaidAmountMap[customer.name] ?? 0.0;

      customer.totalPaid = totalPaidAmount;
      customer.remainingBalance = totalInvoiceAmount - totalPaidAmount;

      customer.save();
    }

    loadCustomers();
  }
}
