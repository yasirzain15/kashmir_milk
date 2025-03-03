// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NotifyScreen extends StatefulWidget {
  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  List<Map<String, String>> users = [];
  TextEditingController messageController = TextEditingController();
  bool isLoading = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Firebase + Hive se users fetch karna
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      // Firestore se users fetch karo
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

      // Hive se users fetch karo
      var box = Hive.box<Customer>('customers');
      List<Map> hiveUsers = box.values.map((user) {
        return {
          "name": user.name,
          "phone": user.phoneNo,
          "milk": user.milkQuantity,
        };
      }).toList();

      // Firebase + Hive users ko merge karna (duplicates hata kar)
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

  // Sab users ko message send karna
  Future<void> sendMessages() async {
    String message = messageController.text.trim();
    if (message.isEmpty) return;

    setState(
      () => progress = 0.0,
    );

    for (int i = 0; i < users.length; i++) {
      await Future.delayed(Duration(seconds: 1));
      sendSms(users[i]["phone"]!, message);
      setState(() => progress = (i + 1) / users.length);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Messages sent!")));
    setState(() {
      progress = 0.0;
      messageController.clear();
    });
  }

  // `url_launcher` se SMS bhejna
  Future<void> sendSms(String phone, String message) async {
    if (phone.isEmpty || message.isEmpty) {
      print("Phone number or message is empty");
      return;
    }

    final Uri smsUri =
        Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print("Could not launch SMS to $phone");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notify Customers",
          style: TextStyle(
            color: Color(0xffffffff),
          ),
        ),
        backgroundColor: Color(0xff78c1f3),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: fetchUsers,
              child: Text("Fetch Customers"),
            ),
            SizedBox(height: 10),
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
            TextFormField(
              controller: messageController,
              decoration: InputDecoration(
                // labelText: "Type your message here",
                hintText: 'Type your message here',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendMessages,
              child: Text("Send Message to All"),
            ),
          ],
        ),
      ),
    );
  }
}
