import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Map<String, dynamic>> customers = [];

  // Fetch all customers from Firestore
  getall() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference userCollection = firestore.collection('csv_data');
    final response = await userCollection.get();
    setState(() {
      customers = response.docs.map((customer) {
        return customer.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xff78c1f3),
        title: Text(
          'All Customers',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xffffffff),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                customers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          // Safely access the address fields and handle null values
                          String fullName =
                              customers[index]["Full Name"] ?? "Unknown";
                          String address = [
                            customers[index]["House No"],
                            customers[index]["Street No"],
                            customers[index]["Sector"],
                            customers[index]["Price/Liter"]
                          ].where((element) => element != null).join(", ");
                          String city = customers[index]["City"] ?? "";

                          return buildCustomerItem(
                              fullName, address, city, index);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extracting the buildCustomerItem function to avoid direct dependency on DashboardScreen
  Widget buildCustomerItem(
      String name, String address, String city, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customers[index]['Price/Liter']?.toString() ?? "N/A",
                      style: const TextStyle(
                        color: Color(0xff78c1f3),
                        fontSize: 12,
                      ),
                    ),
                    const Icon(Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xff12121f),
                    ),
                  ),
                ),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
