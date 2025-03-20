import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:uuid/uuid.dart';

class Funs extends ChangeNotifier {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];

  List<String> sectors = []; // List to store sector names
  List<int> sectorCounts = []; // Store the number of customers in each sector

  Future<void> getall() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('customer');

      final response = await userCollection.get();
      final existedcustomers =
          customers.map((customer) => customer.customerId).toSet();
      final newCustomers = response.docs
          .where((customer) => !existedcustomers.contains(
              (customer.data()! as Map<String, dynamic>)['customer_id']))
          .map((customer) =>
              Customer.fromJson(customer.data() as Map<String, dynamic>))
          .toList();
      customers.addAll(newCustomers);
      filteredCustomers = customers;
      notifyListeners();

      // customers.clear(); // Prevent duplicates by clearing old data
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> getFromHive() async {
    var box = Hive.box<Customer>('customers');

    final response = box.values;

    // Use a Set to keep track of existing customer IDs
    final existingCustomerIds =
        customers.map((customer) => customer.customerId).toSet();

    final newCustomers = response
        .where((customer) => !existingCustomerIds.contains(customer.customerId))
        .map((customer) => customer)
        .toList();

    customers.addAll(newCustomers);
    notifyListeners();
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers =
          customers; // Return all customers if the query is empty
    }
    filteredCustomers = customers.where((customer) {
      final name = customer.name?.toLowerCase() ?? "";
      final city = customer.city?.toLowerCase() ?? "";
      final phone = customer.phoneNo ?? "";
      return name.contains(query.toLowerCase()) ||
          city.contains(query.toLowerCase()) ||
          phone.contains(query.toLowerCase());
    }).toList();
  }

  void deleteCustomer(Customer customer) {
    customers.remove(customer);
    notifyListeners();
  }
}
