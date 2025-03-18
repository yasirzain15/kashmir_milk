import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer? customer;

  CustomerDetailScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('customer')
              .doc(customer!.customerId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Color(0xff78c1f3),
              ));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("Customer data not found"));
            }

            Customer customer = Customer.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Centering Profile Image, Name, and Sector
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                        SizedBox(height: 12),
                        Text(
                          customer.name ?? 'Unknown name',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Sector ${customer.sector ?? 'Unknown sector'}",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff090909),
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Address Section
                  _infoSection("Address :",
                      " House No, ${customer.houseNo ?? 'N/A'}, Street No ${customer.streetNo ?? 'N/A'}, Sector ${customer.sector ?? 'N/A'}"),

                  SizedBox(height: 12),

                  // Call/Message Section
                  _infoSection("Call/Message :", customer.phoneNo ?? 'N/A'),

                  SizedBox(height: 12),

                  // WhatsApp Section
                  _infoSection("WhatsApp :", customer.phoneNo ?? 'N/A'),

                  Spacer(),

                  // Footer Text (Centered)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Powered by :",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          "Elabd Technologies",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff78c1f3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom Function for Info Sections (Left-Aligned)
  Widget _infoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xff78c1f3),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff000000),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
