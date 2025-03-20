import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/send_mesage.dart';
import 'package:kashmeer_milk/customerdetail_screen.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Customer> customers = [];
  String _searchQuery = ""; // Variable to store the search query

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  // Fetch all customers from Firestore and Hive
  Future<void> _fetchCustomers() async {
    List<Customer> hiveCustomers = _getCustomersFromHive();
    List<Customer> firestoreCustomers = await _getCustomersFromFirestore();

    setState(() {
      customers = [...hiveCustomers, ...firestoreCustomers];
    });
  }

  // Fetch customers stored in Hive
  List<Customer> _getCustomersFromHive() {
    final box = Hive.box<Customer>('customers');
    return box.values.toList();
  }

  // Fetch customers from Firestore
  Future<List<Customer>> _getCustomersFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customer')
          .get();

      return snapshot.docs
          .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching Firestore data: $e");
      return [];
    }
  }

  // Function to filter customers based on the search query
  List<Customer> _filterCustomers(List<Customer> customers, String query) {
    if (query.isEmpty) {
      return customers; // Return all customers if the query is empty
    }
    return customers.where((customer) {
      final name = customer.name?.toString().toLowerCase() ?? "";
      final city = customer.city?.toString().toLowerCase() ?? "";
      final phone = customer.phoneNo?.toString().toLowerCase() ?? "";
      return name.contains(query.toLowerCase()) ||
          city.contains(query.toLowerCase()) ||
          phone.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _filterCustomers(customers, _searchQuery);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff78c1f3),
          title: Text(
            "Customers Reports",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Customers',
                  hintStyle: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xffa6a6a6),
                    ),
                  ),
                  filled: true, // Enable background fill
                  fillColor: Color(0x2bc5e0f2), // Set background color
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: filteredCustomers.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Color(0xff78c1f3),
                      ))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return buildCustomerItem(filteredCustomers[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build UI for each customer item
  Widget buildCustomerItem(Customer customer) {
    String name = customer.name ?? "Unknown";
    String city = customer.city ?? "Unknown City";
    String address = [customer.houseNo, customer.streetNo, customer.sector]
        .where((element) => element != null && element.toString().isNotEmpty)
        .join(", ");
    String phone = customer.phoneNo?.toString() ?? "N/A";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailScreen(
              customer: customer,
            ),
          ),
        );
      },
      child: Card(
        color: const Color(0xffffffff),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.isEmpty ? "No Address Provided" : address,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "City: $city",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Phone: $phone",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Milk Quantity: ${customer.milkQuantity ?? "Unknown"}",
                      style: const TextStyle(
                        color: Color(0xff78c1f3),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          SendMessage().sendMessage(customer, context);
                        },
                        child: Container(
                          width: 300,
                          height: 36.53,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff78c1f3),
                                Color(0xff78a2f3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Send Monthly Report',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
