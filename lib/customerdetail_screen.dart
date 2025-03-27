import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer? customer;

  CustomerDetailScreen({required this.customer});

  Future<Customer?> _fetchCustomerData() async {
    var box = await Hive.openBox<Customer>('customers');
    Customer? localCustomer = box.get(customer!.customerId);

    if (localCustomer != null) {
      return localCustomer;
    }

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('customer')
        .doc(customer!.customerId)
        .get();

    if (snapshot.exists) {
      Customer fetchedCustomer =
          Customer.fromJson(snapshot.data() as Map<String, dynamic>);
      await box.put(fetchedCustomer.customerId, fetchedCustomer);
      return fetchedCustomer;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff78c1f3),
          title: Text(
            "Customer Detail",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xffffffff),
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xffffffff),
        body: FutureBuilder<Customer?>(
          future: _fetchCustomerData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: Color(0xff78c1f3),
              ));
            }

            if (!snapshot.hasData) {
              return Center(child: Text("Customer data not found"));
            }

            Customer customer = snapshot.data!;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _infoSection("Address :",
                      "House No, ${customer.houseNo ?? 'N/A'}, Street No ${customer.streetNo ?? 'N/A'}, Sector ${customer.sector ?? 'N/A'}"),
                  SizedBox(height: 12),
                  _infoSection("Call/Message :", customer.phoneNo ?? 'N/A'),
                  SizedBox(height: 12),
                  _infoSection("Whatsapp :", customer.phoneNo ?? 'N/A'),
                  Spacer(),
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
