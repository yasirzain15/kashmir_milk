// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NotifyScreen extends StatefulWidget {
  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  List<Map<String, String>> users = [];
  bool isLoading = false;
  double progress = 0.0;

  final double milkPricePerLiter = 220.0; // Milk price per liter

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      var snapshot = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('customer');
      var querySnapshot = await snapshot.get();
      List<Map<String, dynamic>> firebaseUsers = querySnapshot.docs
          .map((doc) => {
                "name": doc['Full Name'],
                "phone": doc['Phone No'],
                "milk": doc['Milk Quantity'].toString()
              })
          .toList();

      var box = Hive.box<Customer>('customers');
      List<Map> hiveUsers = box.values.map((user) {
        return {
          "name": user.name,
          "phone": user.phoneNo,
          "milk": user.milkQuantity,
        };
      }).toList();

      Set<Map<String, String>> uniqueUsers = {
        ...firebaseUsers
            .map((user) => user.map((k, v) => MapEntry(k, v.toString()))),
        ...hiveUsers
            .map((user) => user.map((k, v) => MapEntry(k, v.toString())))
      };

      setState(() {
        users = uniqueUsers.toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> sendBillsToAll() async {
    setState(() => progress = 0.0);

    for (int i = 0; i < users.length; i++) {
      await Future.delayed(Duration(seconds: 1));
      double milkQuantity = double.tryParse(users[i]["milk"]!) ?? 0.0;
      double totalBill = milkQuantity * milkPricePerLiter;
      String message =
          "Hello ${users[i]["name"]}, your total bill for ${users[i]["milk"]} liters of milk is PKR ${totalBill.toStringAsFixed(2)}.";

      sendSms(users[i]["phone"]!, message);
      setState(() {
        progress = (i + 1) / users.length;
      });
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Bills sent to all customers!")));
    setState(() {
      progress = 0.0;
    });
  }

  Future<void> sendSms(String phone, String message) async {
    if (phone.isEmpty || message.isEmpty) {
      print("Phone number or message is empty");
      return;
    }

    // Normalize the phone number
    String normalizedPhone = phone.replaceAll(
        RegExp(r'[^0-9+]'), ''); // Remove dashes/spaces but keep '+'

    // If the number starts with '03', add '+92' (Pakistan country code)
    if (RegExp(r'^03[0-9]{9}$').hasMatch(normalizedPhone)) {
      normalizedPhone = "+92${normalizedPhone.substring(1)}";
    }

    // Validate phone number
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(normalizedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid phone number format: $phone")),
      );
      return;
    }

    final Uri smsUri =
        Uri.parse("sms:$normalizedPhone?body=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print("Could not launch SMS to $normalizedPhone");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xff78c1f3),
        title: Text(
          "Notify Customers",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(
                              users[index]["name"]!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              "Milk Quantity: ${users[index]["milk"]} L",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Text(
                              users[index]["phone"]!,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                sendBillsToAll();
              },
              child: Container(
                height: 44.53,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withOpacity(0.25),
                      blurRadius: 9,
                      spreadRadius: 0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  height: 44.53,
                  width: 175,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff78c1f3),
                        Color(0xff78a2f3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Bills to All',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xffffffff),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
