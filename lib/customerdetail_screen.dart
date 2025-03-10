// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  CustomerDetailScreen({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Customer data not found"));
          }

          Customer customer =
              Customer.fromJson(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://images.app.goo.gl/BUVB4Q7R3PVaSVoV7',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  customer.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(customer.sector),
                SizedBox(height: 20),
                Text(
                    "Address: ${customer.houseNo}, ${customer.streetNo}, ${customer.sector}"),
                Text("Contact: ${customer.phoneNo}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
