import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double pricePerUnit;

  @HiveField(3)
  DateTime expirationDate;

  Product({
    required this.category,
    required this.quantity,
    required this.pricePerUnit,
    required this.expirationDate,
  });

  bool get isLowStock => quantity < 3;
  bool get isExpiringSoon {
    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    return difference.inDays <= 7 && difference.inDays >= 0;
  }
} 