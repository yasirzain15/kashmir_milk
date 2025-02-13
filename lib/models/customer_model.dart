import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String city;

  @HiveField(2)
  final String sector;

  @HiveField(3)
  final String streetNo;

  @HiveField(4)
  final String houseNo;

  @HiveField(5)
  final String phoneNo;

  @HiveField(6)
  final String milkQuantity;

  @HiveField(7)
  final double estimatedPrice;

  @HiveField(8)
  final double pricePerLiter;

  Customer({
    required this.name,
    required this.city,
    required this.sector,
    required this.streetNo,
    required this.houseNo,
    required this.phoneNo,
    required this.milkQuantity,
    required this.estimatedPrice,
    required this.pricePerLiter,
  });
}
