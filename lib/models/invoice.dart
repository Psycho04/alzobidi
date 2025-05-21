import 'package:hive/hive.dart';
import 'customer.dart';
import 'product.dart';

part 'invoice.g.dart';

@HiveType(typeId: 2)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  Product product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double totalPrice;

  InvoiceItem({
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });
}

@HiveType(typeId: 3)
class Invoice extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  Customer customer;

  @HiveField(2)
  List<InvoiceItem> items;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  double totalAmount;

  @HiveField(5)
  double? paidAmount;

  @HiveField(6)
  bool isPaid;

  Invoice({
    required this.id,
    required this.customer,
    required this.items,
    required this.date,
    required this.totalAmount,
    this.paidAmount,
    this.isPaid = false,
  });

  static const String institutionName = 'Mohammed Ali Bakri Al-Zubaidi Veterinary Institution';
  static const String taxNumber = '192903904';
  static const String commercialRegistrationNumber = '5851879775';
} 