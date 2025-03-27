import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class NotifyScreen extends StatefulWidget {
  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  List<Customer> users = [];
  bool isLoading = false;
  double progress = 0.0;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      var snapshot = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('customer');
      var querySnapshot = await snapshot.get();
      List<Map<String, dynamic>> firebaseUsers =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      var box = Hive.box<Customer>('customers');
      List<Customer> hiveUsers = box.values.map((user) {
        return Customer();
      }).toList();

      Set<Customer> uniqueUsers = {
        ...firebaseUsers.map((user) => Customer.fromJson(user)),
        ...hiveUsers
      };

      setState(() {
        users = uniqueUsers.toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> sendMessagesToAll() async {
    if (messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a message"),
          backgroundColor: Color(0xffff2c2c),
        ),
      );
      return;
    }

    setState(() => progress = 0.0);

    if (await Permission.sms.request().isGranted) {
      for (int i = 0; i < users.length; i++) {
        await sendSms(users[i].phoneNo ?? '', messageController.text);

        setState(() {
          progress = (i + 1) / users.length;
        });
        await Future.delayed(Duration(milliseconds: 500));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Messages sent to all customers!"),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xff78c1f3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("SMS permission denied"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => progress = 0.0);
  }

  Future<void> sendSms(String phone, String message) async {
    if (phone.isEmpty || message.isEmpty) return;

    // Normalize phone number
    String normalizedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Convert '03xxxxxxxxx' to '+92xxxxxxxxxx'
    if (RegExp(r'^03[0-9]{9}$').hasMatch(normalizedPhone)) {
      normalizedPhone = "+92${normalizedPhone.substring(1)}";
    }

    try {
      await sendSMS(
        message: message,
        recipients: [normalizedPhone],
        sendDirect: true,
      );
    } catch (e) {
      print("Error sending SMS: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xff78c1f3),
        title: Text(
          "Notify Customers",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color of the TextField
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Shadow color
                          spreadRadius: 2, // How much the shadow spreads
                          blurRadius: 5, // Blur radius for softness
                          offset: Offset(0, 3), // Position of shadow (x, y)
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(
                          color: Color(0xffa6a6a6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Match container's radius
                          borderSide: BorderSide.none, // Hide default border
                        ),
                        // enabledBorder: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(10),
                        //   // borderSide:
                        //   //     BorderSide(color: Color(0xff78c1f3), width: 1),
                        // ),
                        // focusedBorder: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(10),
                        //   // borderSide:
                        //   //     BorderSide(color: Color(0xff78c1f3), width: 2),
                        // ),
                        filled: true,
                        fillColor: Colors
                            .white, // Ensure text field matches container color
                        contentPadding:
                            EdgeInsets.all(16), // Padding inside the field
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Example: "We are not available today. Milk delivery will resume Soon."',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                sendMessagesToAll();
              },
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send Message',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ),
                      SizedBox(width: 11),
                      Icon(
                        Icons.send,
                        color: Color(0xffffffff),
                      ),
                    ],
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
