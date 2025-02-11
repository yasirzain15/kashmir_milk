import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/see_all_screen.dart';
import 'package:kashmeer_milk/send_mesage.dart';

class RecentCustomers extends StatefulWidget {
  const RecentCustomers({super.key});

  @override
  State<RecentCustomers> createState() => _RecentCustomersState();
}

class _RecentCustomersState extends State<RecentCustomers> {
  List<Map<String, dynamic>> customers = [];

  // Fetch all customers from Firestore
  Future<void> getall() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore.collection('customers');
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
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xff78c1f3),
        title: Text(
          'Recent Customers',
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
                    return CustomerItem(
                      name: customers[index]["Full Name"] ?? "Unknown",
                      city: customers[index]["City"] ?? "Unknown",
                      phone: customers[index]["Phone No"] ?? "Unknown",
                      mq: customers[index]["Milk Quantity"] ?? "Unknown",
                      index: index,
                      customers: customers,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class CustomerItem extends StatelessWidget {
  final String name;
  final String city;
  final String phone;
  final String mq;
  List<Map<String, dynamic>> customers = [];
  int index;
  CustomerItem(
      {Key? key,
      required this.name,
      required this.city,
      required this.phone,
      required this.mq,
      required this.index,
      required this.customers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    "Milk Quantity: $mq liters",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff78c1f3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
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
