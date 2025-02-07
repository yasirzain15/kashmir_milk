// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/add_customer.dart';
import 'package:kashmeer_milk/multiple_entries.dart';
import 'package:kashmeer_milk/recent_customers.dart';
import 'package:kashmeer_milk/see_all_screen.dart';

// You'll need to add this package

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    ),
                    Text(
                      "Good Morning, Abdul!",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xff78c1f3),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Cards
                _buildStatsCard("Our Customers", "306.98"),
                const SizedBox(height: 16),
                _buildStatsCard("Our Areas", "306.98"),
                const SizedBox(height: 24),

                // Recent Customers Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecentCustomers(),
                          ),
                        );
                      },
                      child: Text(
                        "Recent Customers",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff1976d2),
                          ),
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
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return buildCustomerItem();
                    },
                  ),
                ),

                // Bottom Buttons
                Row(
                  children: [
                    Expanded(
                      child: PopupMenuButton(
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
                            color: Color(0xff78c1f3),
                          ),
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
                      child: Container(
                        height: 44.53,
                        width: 175,
                        decoration: BoxDecoration(
                          color: Color(0xff78c1f3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notification_add,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 31),
      child: Container(
        height: 154,
        width: 327,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[300]!],
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
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
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
                      barWidth: 2,
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

  Widget buildCustomerItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/ahmad.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "05:00 PM",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
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
                  'Anum Fatima',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xff12121f),
                    ),
                  ),
                ),
                Text(
                  "House no 203, Street 92, G11/3",
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
      ),
    );
  }
}
