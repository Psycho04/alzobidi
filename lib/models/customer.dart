import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String whatsappNumber;

  @HiveField(2)
  double totalPaid;

  @HiveField(3)
  double remainingBalance;

  Customer({
    required this.name,
    required this.whatsappNumber,
    this.totalPaid = 0.0,
    this.remainingBalance = 0.0,
  });
} 