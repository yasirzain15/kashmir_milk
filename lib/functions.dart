import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:uuid/uuid.dart';

class Funs extends ChangeNotifier {
  List<Map<String, dynamic>> customers = [];
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
      final existedcustomers = customers.map((e) => e['customer_id']).toSet();
      final newCustomers = response.docs
          .where((customer) => !existedcustomers.contains(
              (customer.data()! as Map<String, dynamic>)['customer_id']))
          .map((customer) => customer.data() as Map<String, dynamic>)
          .toList();
      customers.addAll(newCustomers);
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
    final existingCustomerIds = customers.map((e) => e['customer_id']).toSet();

    final newCustomers = response
        .where((customer) => !existingCustomerIds.contains(customer.customerId))
        .map((customer) => customer.toJson())
        .toList();

    customers.addAll(newCustomers);
    notifyListeners();
  }

  Future<void> fetchSectors() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('your_user_id') // Replace with actual user ID
          .collection('customer')
          .get();

      // Create a Map to count occurrences of each sector
      Map<String, int> sectorMap = {};

      for (var doc in snapshot.docs) {
        String sector = doc['Sector'] as String;
        sectorMap[sector] = (sectorMap[sector] ?? 0) + 1;
      }

      sectors = sectorMap.keys.toList(); // Get unique sector names
      sectorCounts = sectorMap.values.toList(); // Get counts of each sector

      notifyListeners();
    } catch (e) {
      print("Error fetching sectors: $e");
    }
  }
}
