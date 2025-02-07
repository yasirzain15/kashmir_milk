import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Map<String, dynamic>> customers = [];
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
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xff78c1f3),
        title: Text(
          'All Customers',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
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
                    ? SizedBox()
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return DashboardScreen()
                              .buildCustomerItem(customers[index]["Full Name"]);
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
