import 'package:flutter/material.dart';
import 'package:kashmeer_milk/dashboard.dart';

class RecentCustomers extends StatefulWidget {
  const RecentCustomers({super.key});

  @override
  State<RecentCustomers> createState() => _RecentCustomersState();
}

class _RecentCustomersState extends State<RecentCustomers> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for customers',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 34,
                    itemBuilder: (context, index) {
                      return DashboardScreen().buildCustomerItem();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
