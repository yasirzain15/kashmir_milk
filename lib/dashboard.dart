// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Add customers/add_customer.dart';
import 'package:kashmeer_milk/Add Customers/multiple_entries.dart';
import 'package:kashmeer_milk/Login/login_screen.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:kashmeer_milk/billing_screen.dart';
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
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<Funs>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 100), () {
      provider.getall();
      provider.getFromHive();

      loadCustomerData();
      fetchTotalCustomers();
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
    } else if (hour >= 12 && hour < 16) {
      greeting = "Good Afternoon";
    } else if (hour >= 16 && hour < 20) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }
  }

  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully!"),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xff78c1f3),
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton(
                      color: Color(0xffffffff),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            title: Text(
                              'Profile',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xff12121f),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              'Profile Details',
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
                        PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            title: Text(
                              'Manage Payments',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xff12121f),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              'Manage Payment records',
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
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            title: Text(
                              'Quick Alerts',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xff12121f),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              'Send Quick Alerts for',
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
                        PopupMenuItem(
                          value: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BillingScreen()));
                            },
                            child: ListTile(
                              title: Text(
                                'Reports',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xff12121f),
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                'Generate and Share reports',
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
                          value: 1,
                          child: GestureDetector(
                            onTap: () {
                              _logoutUser();
                            },
                            child: ListTile(
                              title: Text(
                                'Log Out',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xff12121f),
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                'Logout',
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
                      child: Icon(
                        Icons.segment_outlined,
                        color: Color(0xff000000),
                      ),
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
                    PopupMenuButton(
                      color: Color(0xffffffff),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SeeallScreen(),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text('Send Reports'),
                              leading: SvgPicture.asset(
                                'assets/speed.svg',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotifyScreen(),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text('Send Message to All'),
                              leading: Icon(
                                Icons.message_outlined,
                                color: Color(0xff78c1f3),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          bottom: 75, // Adjust position
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
                                  offset: const Offset(2, 2),
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
                const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _imageList.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        _currentIndex = entry.key;
                      }),
                      child: Container(
                        width: 10.34,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _currentIndex == entry.key
                              ? LinearGradient(
                                  colors: [
                                    Color(0xff78c1f3),
                                    Color(0xff78a2f3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    const Color.fromRGBO(189, 189, 189, 1),
                                    Colors.grey.shade400,
                                  ], // Solid color as a gradient
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23),
                      child: Text(
                        'My Customers',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: SingleChildScrollView(
                    child: Consumer<Funs>(
                      builder: (context, provider, child) => TextFormField(
                        controller: _customerController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search Customers',
                          hintStyle: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xffa6a6a6),
                            ),
                          ),
                          filled: true, // Enable background fill
                          fillColor: Color(0x2bc5e0f2), // Set background color
                        ),
                        onChanged: (value) {
                          provider.filterCustomers(value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 51,
                ),

                // Recent Customers Header

                const SizedBox(height: 16),

                // Customer List
                Expanded(
                  child: Consumer<Funs>(
                    builder: (context, provider, child) {
                      // Filter customers based on the search query

                      return ListView.separated(
                        itemCount: provider.filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return CustomerItem(
                            customer: provider.filteredCustomers[index],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: SvgPicture.asset('assets/home.svg',
                    height: 30,
                    width: 30,
                    color: _selectedIndex == 0
                        ? Color(0xff292d32)
                        : Color(0xffafafbd)),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/food.svg',
                    height: 30,
                    width: 30,
                    color: _selectedIndex == 1
                        ? Color(0xff292d32)
                        : Color(0xffafafbd)),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: SvgPicture.asset('assets/pay.svg',
                    height: 30,
                    width: 30,
                    color: _selectedIndex == 2
                        ? Color(0xff292d32)
                        : Color(0xffafafbd)),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/profile.svg',
                    height: 30,
                    width: 30,
                    color: _selectedIndex == 3
                        ? Color(0xff292d32)
                        : Color(0xffafafbd)),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xff78c1f3),
                    Color(0xff78a2f3)
                  ], // Gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffafafbd),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                // Add your logic here
              },
              elevation: 0,
              shape: const CircleBorder(),
              backgroundColor: Colors.transparent,
              child: PopupMenuButton(
                color: Color(0xffffffff),
                icon: const Icon(Icons.add, color: Colors.white),
                onSelected: (value) {
                  // Handle selection
                },
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
                            builder: (context) => const CsvExcelUploader(),
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
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class CustomerItem extends StatefulWidget {
  final Customer customer;

  const CustomerItem({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerItem> createState() => _CustomerItemState();
}

class _CustomerItemState extends State<CustomerItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Funs>(
      builder: (context, provider, child) => Card(
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
                      widget.customer.name ?? "Unknown",
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
                      widget.customer.city ?? "Unknown",
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
                      widget.customer.phoneNo ?? "Unknown",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.customer.milkQuantity ?? "Unknown",
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
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                      value: 1,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await removeCustomerData(
                              widget.customer.customerId ?? '', context);
                          provider.deleteCustomer(widget.customer);
                        },
                        child: ListTile(
                          title: Text(
                            'Remove Customer',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xff292929),
                              ),
                            ),
                          ),
                          subtitle: Text(
                            'Remove this customer from list',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Color(0xffafafbd),
                              ),
                            ),
                          ),
                        ),
                      )),
                  PopupMenuItem<int>(
                      value: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerRegistrationForm(
                                customer: widget.customer,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            'Update Customer',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xff292929),
                            )),
                          ),
                          subtitle: Text(
                            'Update Customer record',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Color(0xffafafbd),
                            )),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> removeCustomerData(
      String customerId, BuildContext context) async {
    try {
      // Remove customer from Firebase
      var docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('customer')
          .doc(customerId);

      var doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer removed successfully from Firebase ✅"),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
        // Refresh the customer list in the provider
        await Provider.of<Funs>(context, listen: false).getall();
        await Provider.of<Funs>(context, listen: false).getFromHive();
      }

      // Remove customer from Hive using .where()

      final box = Hive.box<Customer>('customers');

      // Find the key using values instead of keys
      final keyToDelete = box.keys.firstWhere(
        (key) {
          final customer = box.get(key);
          return customer != null && customer.customerId == customerId;
        },
        orElse: () => null,
      );

      if (keyToDelete != null) {
        await box.delete(keyToDelete);

        // Refresh the customer list in the provider
        await Provider.of<Funs>(context, listen: false).getFromHive();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer removed from Local Storage ✅"),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer not found in Local Storage ❌"),
            backgroundColor: Color(0xffc30010),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove customer from Hive: $e"),
          backgroundColor: Color(0xffc30010),
        ),
      );
    }
  }
}
