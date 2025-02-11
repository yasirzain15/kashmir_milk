// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/send_mesage.dart';
import 'package:url_launcher/url_launcher.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Map<String, dynamic>> customers = [];

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

  @override
  void initState() {
    super.initState();
    getall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff78c1f3),
        title: Text(
          'All Customers',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: customers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    return buildCustomerItem(index);
                  },
                ),
        ),
      ),
    );
  }

  // Function to send an SMS to the customer

  // Build UI for each customer item
  Widget buildCustomerItem(int index) {
    String name = customers[index]["Full Name"] ?? "Unknown";
    String city = customers[index]["City"] ?? "Unknown City";
    String address = [
      customers[index]["House No"],
      customers[index]["Street No"],
      customers[index]["Sector"]
    ]
        .where((element) => element != null && element.toString().isNotEmpty)
        .join(", ");
    String phone = customers[index]['Phone No']?.toString() ?? "N/A";
    String pricePerLiter = customers[index]['Price/Liter']?.toString() ?? "N/A";

    return Card(
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
                ],
              ),
            ),
            PopupMenuButton<int>(
              color: Color(0xffffffff),
              onSelected: (value) {
                if (value == 1) {
                  SendMessage().sendMessage(index, customers, context);
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
