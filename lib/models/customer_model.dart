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
    required this.pricePerLiter,
  });

  /// Convert JSON Map to `Customer` object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['Full Name'].toString(),
      city: json['City'].toString(),
      sector: json['Sector'].toString(),
      streetNo: json['Street No'].toString(),
      houseNo: json['House No'].toString(),
      phoneNo: json['Phone No'].toString(),
      milkQuantity: json['Milk Quantity'].toString(),
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
      'Price/Liter': pricePerLiter,
    };
  }
}
