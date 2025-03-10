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

  @HiveField(9)
  final String customerId;

  Customer({
    required this.name,
    required this.city,
    required this.sector,
    required this.streetNo,
    required this.houseNo,
    required this.phoneNo,
    required this.milkQuantity,
    required this.pricePerLiter,
    required this.customerId,
  });

  /// Convert JSON Map to `Customer` object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['Full Name']?.toString() ?? 'Unknown Name',
      city: json['City']?.toString() ?? 'Unknown City',
      sector: json['Sector']?.toString() ?? 'Unknown Sector',
      streetNo: json['Street No']?.toString() ?? 'Unknown Street',
      houseNo: json['House No']?.toString() ?? "Unknown House",
      phoneNo: json['Phone No']?.toString() ?? 'Unknown Phone',
      milkQuantity: json['Milk Quantity']?.toString() ?? "Unknown",
      pricePerLiter: (json['Price/Liter'] as num).toDouble(),
      customerId: json['customer_id'] ?? ''.toString(),
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
      'customer_id': customerId,
    };
  }
}
