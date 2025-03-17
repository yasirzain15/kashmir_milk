import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDetailScreen extends StatelessWidget {
  // final String customerId;
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
              // Debug: Print the customerId and snapshot data

              return Center(child: Text("Customer data not found"));
            }

            Customer customer = Customer.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    SizedBox(height: 24),
                    Text(
                      customer.name ?? 'Unknown name',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text("Sector ${customer.sector ?? 'Unknown sector'}",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff090909),
                          ),
                        )),
                    SizedBox(height: 84),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Address :',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff78c1f3),
                              ),
                            ),
                          ),
                          Text(
                            "${customer.houseNo ?? 'N/A'}, ${customer.streetNo ?? 'N/A'}, ${customer.sector ?? 'N/A'}",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                            )),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Call/Message :',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff78c1f3),
                            )),
                          ),
                          Text(
                            customer.phoneNo ?? 'N/A',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
