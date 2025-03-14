import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  CustomerDetailScreen({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('customers')
              .doc(customerId)
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
                    customer.name ?? 'Unknown name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(customer.sector ?? 'Unknown sector'),
                  SizedBox(height: 20),
                  Text(
                      "Address: ${customer.houseNo ?? 'N/A'}, ${customer.streetNo ?? 'N/A'}, ${customer.sector ?? 'N/A'}"),
                  Text("Contact: ${customer.phoneNo ?? 'N/A'}"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
