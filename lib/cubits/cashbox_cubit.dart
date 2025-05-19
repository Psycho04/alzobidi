import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../models/invoice.dart';
import '../models/product.dart';

// Events
abstract class CashboxEvent extends Equatable {
  const CashboxEvent();

  @override
  List<Object> get props => [];
}

class LoadCashboxData extends CashboxEvent {}

// State
class CashboxState extends Equatable {
  final double totalSales;
  final double totalPurchases;
  final double totalProfit;

  const CashboxState({
    this.totalSales = 0.0,
    this.totalPurchases = 0.0,
    this.totalProfit = 0.0,
  });

  CashboxState copyWith({
    double? totalSales,
    double? totalPurchases,
    double? totalProfit,
  }) {
    return CashboxState(
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalProfit: totalProfit ?? this.totalProfit,
    );
  }

  @override
  List<Object> get props => [totalSales, totalPurchases, totalProfit];
}

// Cubit
class CashboxCubit extends Cubit<CashboxState> {
  final Box<Invoice> _invoicesBox;
  final Box<Product> _productsBox;

  CashboxCubit(this._invoicesBox, this._productsBox)
      : super(const CashboxState()) {
    loadCashboxData();
  }

  void loadCashboxData() {
    final invoices = _invoicesBox.values.toList();
    final products = _productsBox.values.toList();

    final totalSales = invoices.fold<double>(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );

    final totalPurchases = products.fold<double>(
      0.0,
      (sum, product) => sum + (product.pricePerUnit * product.quantity),
    );

    final totalProfit = totalSales - totalPurchases;

    emit(CashboxState(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalProfit: totalProfit,
    ));
  }

  // Method to update cashbox data when an invoice is added or deleted
  void updateCashbox() {
    loadCashboxData();
  }
}
