// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Add customers/add_customer.dart'; // Ensure this file exists
import 'package:kashmeer_milk/Add Customers/multiple_entries.dart'; // Ensure this file exists
import 'package:kashmeer_milk/Login/login_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/message_screen.dart';
import 'package:kashmeer_milk/see_all_screen.dart';
import 'package:kashmeer_milk/send_mesage.dart';
import 'package:provider/provider.dart'; // Ensure this file exists
// Ensure this file exists
// Ensure this file exists

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String greeting = "Hello";
  int totalCustomers = 0;
  List<String> uniqueSectors = [];
  DateTime? lastBackPress;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<Funs>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 100), () {
      provider.getall();
      provider.getFromHive();
      Provider.of<Funs>(context, listen: false).fetchSectors();
      loadCustomerData();
      fetchUniqueSectors();
    });
    updateGreeting();
  }

  Future<void> fetchUniqueSectors() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('customer')
          .get();

      List<String> sectors =
          snapshot.docs.map((doc) => doc['Sector'] as String).toSet().toList();

      setState(() {
        uniqueSectors = sectors;
      });
    } catch (e) {
      setState(() {
        uniqueSectors = [];
      });
    }
  }

  Future<int> fetchTotalCustomers() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('customer')
          .get();

      return snapshot.docs.length; // Total customers count
    } catch (e) {
      return 0;
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (lastBackPress == null ||
        now.difference(lastBackPress!) > Duration(seconds: 2)) {
      lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Press back again to exit"),
          backgroundColor: Color(0xff78c1f3),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    SystemNavigator.pop(); // Exit the app
    return true;
  }

  Future<void> loadCustomerData() async {
    int count = await fetchTotalCustomers();
    setState(() {
      totalCustomers = count;
    });
  }

  void updateGreeting() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }
  }

  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully!")),
      );

      // Navigate to Login Screen (Replace with your actual login screen)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$greeting ,${FirebaseAuth.instance.currentUser!.displayName}",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xff78c1f3),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.power_settings_new,
                            size: 35,
                            color: Color(0xffff2c2c),
                          ),
                          onPressed: () async {
                            await _logoutUser();
                            // You can add functionality to open a menu
                          },
                        ),
                      ]),
                  const SizedBox(height: 20),

                  // Stats Cards
                  _buildStatsCard("Our Customers", "$totalCustomers"),
                  SizedBox(
                    height: 16,
                  ),
                  _buildStatsCard("Our Areas", uniqueSectors.join(", ")),

                  const SizedBox(height: 24),

                  // Recent Customers Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Customers",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff1976d2),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SeeallScreen()));
                        },
                        child: Text(
                          "See all",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff1976d2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Customer List
                  Expanded(
                    child: Consumer<Funs>(
                      builder: (context, provider, child) => ListView.separated(
                        itemCount: provider
                            .customers.length, // Dynamically get customer data
                        itemBuilder: (context, index) {
                          return CustomerItem(
                            customer: provider.customers[index],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                      ),
                    ),
                  ),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton(
                          color: Color(0xffffffff),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerRegistrationForm(),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Text(
                                    'Single Entry',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Color(0xff292929),
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Add Only One Customer',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: Color(0xffafafbd),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CsvExcelUploader(),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Text(
                                    'Multiple Entries',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Color(0xff292929),
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Add Multiple Customers',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: Color(0xffafafbd),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            height: 44.53,
                            width: 175,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              colors: [
                                Color(0xff78c1f3),
                                Color(
                                  0xff78a2f3,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 13),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Color(0xffffffff),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Add New',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotifyScreen()));
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
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notification_add_outlined,
                                    color: Color(0xffffffff),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Notify',
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
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 31),
      child: Container(
        height: 154,
        width: 350,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
          gradient: LinearGradient(
            colors: [
              Color(0xff78c1f3),
              Color(0xff78a2f3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.josefinSans(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  color: Color(0xffffffff),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.josefinSans(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xffffffff),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2, 2),
                        const FlSpot(4, 5),
                        const FlSpot(6, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(10, 3),
                      ],
                      isCurved: true,
                      color: Colors.white.withOpacity(0.8),
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerItem(String name, String address) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1/2 Liter",
                    style: TextStyle(
                      color: Color(0xff78c1f3),
                      fontSize: 12,
                    ),
                  ),
                  Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xff12121f),
                  ),
                ),
              ),
              Text(
                address,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomerItem extends StatelessWidget {
  Map<String, dynamic> customer;

  CustomerItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xffffffff),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['Full Name'] ?? "Unknown",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  Text(
                    "City: ${customer['City'] ?? "Unknown"}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Phone: ${customer['Phone No'] ?? "Unknown"}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Milk Quantity: ${customer['Milk Quantity'] ?? "Unknown"}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff78c1f3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
              color: Color(0xffffffff),
              onSelected: (value) {
                SendMessage().sendMessage(customer, context);
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Send Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
