// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/send_mesage.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Map<String, dynamic>> customers = [];
  String _searchQuery = ""; // Variable to store the search query

  // Fetch all customers from Firestore
  Future<void> getall() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore.collection('csv_data');
      final response = await userCollection.get();

      setState(() {
        customers = response.docs.map((customer) {
          return customer.data() as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  // Function to filter customers based on the search query
  List<Map<String, dynamic>> _filterCustomers(
      List<Map<String, dynamic>> customers, String query) {
    if (query.isEmpty) {
      return customers; // Return all customers if the query is empty
    }
    return customers.where((customer) {
      final name = customer['Full Name']?.toString().toLowerCase() ?? "";
      final city = customer['City']?.toString().toLowerCase() ?? "";
      final phone = customer['Phone No']?.toString().toLowerCase() ?? "";
      return name.contains(query.toLowerCase()) ||
          city.contains(query.toLowerCase()) ||
          phone.contains(query.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<Funs>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 100), () async {
      await getall();
      await provider.getall();
      await provider.getFromHive();

      setState(() {
        customers.addAll(provider.customers);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter customers based on the search query
    final filteredCustomers = _filterCustomers(customers, _searchQuery);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
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
                      _searchQuery = value; // Update the search query
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
      ),
    );
  }

  // Build UI for each customer item
  Widget buildCustomerItem(Map<String, dynamic> customer) {
    String name = customer["Full Name"] ?? "Unknown";
    String city = customer["City"] ?? "Unknown City";
    String address = [
      customer["House No"],
      customer["Street No"],
      customer["Sector"]
    ]
        .where((element) => element != null && element.toString().isNotEmpty)
        .join(", ");
    String phone = customer['Phone No']?.toString() ?? "N/A";
    String pricePerLiter = customer['Price/Liter']?.toString() ?? "N/A";

    return Card(
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
                    "Price: Rs. $pricePerLiter /L",
                    style: const TextStyle(
                      color: Color(0xff78c1f3),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
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
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
              color: const Color(0xffffffff),
              onSelected: (value) {
                if (value == 1) {
                  SendMessage().sendMessage(customer, context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Send Message'),
                ),
              ],
              child: const Icon(Icons.more_horiz),
            ),
          ],
        ),
      ),
    );
  }
}
