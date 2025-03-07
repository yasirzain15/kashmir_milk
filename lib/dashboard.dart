// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Add customers/add_customer.dart';
import 'package:kashmeer_milk/Add Customers/multiple_entries.dart';
import 'package:kashmeer_milk/Login/login_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/message_screen.dart';
import 'package:kashmeer_milk/see_all_screen.dart';
import 'package:kashmeer_milk/send_mesage.dart';
import 'package:provider/provider.dart';

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
  int _currentIndex = 0;
  final TextEditingController _customerController = TextEditingController();
  final List<String> _imageList = [
    'assets/image.png',
    'assets/image.png',
    'assets/image.png',
    'assets/image.png', // Add your images in assets folder
  ];
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        now.difference(lastBackPress!) > const Duration(seconds: 2)) {
      lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to exit"),
          backgroundColor: Color(0xffff2c2c),
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
        const SnackBar(
          content: Text("Logged out successfully!"),
          duration: Duration(seconds: 1),
        ),
      );

      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 1),
        ),
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
                    const Icon(
                      Icons.segment_outlined,
                      color: Color(0xff000000),
                    ),
                    Text(
                      "$greeting, ${FirebaseAuth.instance.currentUser!.displayName}",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xff78c1f3),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bolt_outlined,
                        color: Color(0xff1976d2),
                      ),
                      onPressed: _logoutUser,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Carousel Slider
                CarouselSlider(
                  items: _imageList.map((imagePath) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: 1000,
                          ),
                        ),
                        Positioned(
                          right: 20, // Adjust position
                          bottom: 40, // Adjust position
                          child: Text(
                            "We have\nso fresh milk",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _imageList.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        _currentIndex = entry.key;
                      }),
                      child: Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? Colors.grey.shade400
                              : Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'My Customers',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                  child: SingleChildScrollView(
                    child: TextFormField(
                      controller: _customerController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Customers',
                        filled: true, // Enable background fill
                        fillColor: Colors.grey.shade100, // Set background color
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                // Recent Customers Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Customers",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
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
                            builder: (context) => const SeeallScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "See all",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff1976d2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer List
                Expanded(
                  child: Consumer<Funs>(
                    builder: (context, provider, child) => ListView.separated(
                      itemCount: provider.customers.length,
                      itemBuilder: (context, index) {
                        return CustomerItem(
                          customer: provider.customers[index],
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                ),

                // Bottom Buttons
                Row(
                  children: [
                    Expanded(
                      child: PopupMenuButton(
                        color: const Color(0xffffffff),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerRegistrationForm(),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  'Single Entry',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xff292929),
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  'Add Only One Customer',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
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
                            value: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CsvExcelUploader(),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  'Multiple Entries',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xff292929),
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  'Add Multiple Customers',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
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
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff78c1f3),
                                Color(0xff78a2f3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add New',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
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
                              builder: (context) => NotifyScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 44.53,
                          width: 175,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff78c1f3),
                                Color(0xff78a2f3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notification_add_outlined,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notify',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
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
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.grey),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.local_shipping, color: Colors.grey),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 48),
              IconButton(
                icon: Icon(Icons.attach_money, color: Colors.grey),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.grey),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          shape: CircleBorder(),
          backgroundColor: Colors.blueAccent,
          child: PopupMenuButton(
            icon: Icon(Icons.add, color: Colors.white),
            onSelected: (value) {
              // Handle selection
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text('Single Entry')),
              PopupMenuItem(value: 2, child: Text('Multiple Entries')),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class CustomerItem extends StatelessWidget {
  final Map<String, dynamic> customer;

  const CustomerItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffffffff),
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
              color: const Color(0xffffffff),
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
