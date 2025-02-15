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

  /// Convert JSON Map to `Customer` object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['Full Name'],
      city: json['City'],
      sector: json['Sector'],
      streetNo: json['Street No'],
      houseNo: json['House No'],
      phoneNo: json['Phone No'],
      milkQuantity: json['Milk Quantity'],
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      pricePerLiter: (json['Price/Liter'] as num).toDouble(),
    );
  }

  /// Convert `Customer` object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'Full Name': name,
      'City': city,
      'Sector': sector,
      'Street No': streetNo,
      'House No': houseNo,
      'Phone No': phoneNo,
      'Milk Quantity': milkQuantity,
      'estimated_price': estimatedPrice,
      'Price/Liter': pricePerLiter,
    };
  }
}
