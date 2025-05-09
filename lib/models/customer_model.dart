import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  final String? name;

  @HiveField(1)
  final String? city;

  @HiveField(2)
  final String? sector;

  @HiveField(3)
  final String? streetNo;

  @HiveField(4)
  final String? houseNo;

  @HiveField(5)
  final String? phoneNo;

  @HiveField(6)
  final String? milkQuantity;

  @HiveField(7)
  final double? pricePerLiter;

  @HiveField(8)
  final String? customerId;

  Customer({
    this.name,
    this.city,
    this.sector,
    this.streetNo,
    this.houseNo,
    this.phoneNo,
    this.milkQuantity,
    this.pricePerLiter,
    this.customerId,
  });

  /// Convert JSON Map to `Customer` object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['Full Name']?.toString(),
      city: json['City']?.toString(),
      sector: json['Sector']?.toString(),
      streetNo: json['Street No']?.toString(),
      houseNo: json['House No']?.toString(),
      phoneNo: json['Phone Number'] ?? json["Phone No"],
      milkQuantity: json['Milk Quantity']?.toString(),
      pricePerLiter: double.tryParse(json['Price/Liter']?.toString() ?? '0'),
      customerId: json['customer_id']?.toString(),
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
      'Phone Number': phoneNo,
      'Milk Quantity': milkQuantity,
      'Price/Liter': pricePerLiter,
      'customer_id': customerId,
    };
  }
}
