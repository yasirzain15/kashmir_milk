import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';

class Funs extends ChangeNotifier {
  List<Map<String, dynamic>> customers = [];
  Future<void> getall() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore.collection('customers');
      final response = await userCollection.get();

      final firebasecustomers = response.docs.map((customer) {
        return customer.data() as Map<String, dynamic>;
      }).toList();
      customers.addAll(firebasecustomers);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> getFromHive() async {
    var box = Hive.box<Customer>('customers');

    final response = box.values;
    final localcustomers = response.map((customer) {
      return (customer).toJson();
    }).toList();
    customers.addAll(localcustomers);
    notifyListeners();
  }
}
