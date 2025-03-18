import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  SizedBox(height: 12),

                  // Name and Sector
                  Text(
                    customer.name ?? 'Unknown name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  ),

                  SizedBox(height: 20),

                  // Action Buttons (Call, Message, WhatsApp)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton("Call", Colors.grey[200], () {
                        _launchURL("tel:${customer.phoneNo}");
                      }),
                      SizedBox(width: 8),
                      _actionButton("Message", Colors.grey[200], () {
                        _launchURL("sms:${customer.phoneNo}");
                      }),
                      SizedBox(width: 8),
                      _actionButton("WhatsApp", Color(0xff78c1f3), () {
                        _launchURL("https://wa.me/${customer.phoneNo}");
                      }),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Address Section
                  _infoSection("Address :",
                      "${customer.houseNo ?? 'N/A'}, ${customer.streetNo ?? 'N/A'}, ${customer.sector ?? 'N/A'}"),

                  // Call/Message Section
                  _infoSection("Call/Message :", customer.phoneNo ?? 'N/A'),

                  // WhatsApp Section
                  _infoSection("WhatsApp :", customer.phoneNo ?? 'N/A'),

                  Spacer(),

                  // Footer Text
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
            );
          },
        ),
      ),
    );
  }

  // Custom Function for Info Sections
  Widget _infoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xff78c1f3),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Function for Action Buttons
  Widget _actionButton(String text, Color? color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // Function to Handle URL Launch
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
