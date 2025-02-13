// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 0;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      name: fields[0] as String,
      city: fields[1] as String,
      sector: fields[2] as String,
      streetNo: fields[3] as String,
      houseNo: fields[4] as String,
      phoneNo: fields[5] as String,
      milkQuantity: fields[6] as String,
      estimatedPrice: fields[7] as double,
      pricePerLiter: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.sector)
      ..writeByte(3)
      ..write(obj.streetNo)
      ..writeByte(4)
      ..write(obj.houseNo)
      ..writeByte(5)
      ..write(obj.phoneNo)
      ..writeByte(6)
      ..write(obj.milkQuantity)
      ..writeByte(7)
      ..write(obj.estimatedPrice)
      ..writeByte(8)
      ..write(obj.pricePerLiter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
