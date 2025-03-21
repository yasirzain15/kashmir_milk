import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:uuid/uuid.dart';

class Funs extends ChangeNotifier {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];

  List<String> sectors = []; // List to store sector names
  List<int> sectorCounts = []; // Store the number of customers in each sector

  Future<void> getall() async {
    try {
      customers.clear();
      filteredCustomers.clear();
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

  Future<bool> checkInternet(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult
        .any((element) => element == ConnectivityResult.none)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer removed successfully"),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xff78c1f3),
        ),
      );
      return false;
    }
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5)); // Timeout after 5 seconds

      if (response.statusCode == 200) {
        return true; // Internet is working
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Internet: Failed to reach server"),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet: Saved Offline !!"),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xffc30010),
        ),
      );
      return false;
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
