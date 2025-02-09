// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:kashmeer_milk/dashboard.dart';

class RecentCustomers extends StatefulWidget {
  const RecentCustomers({super.key});

  @override
  State<RecentCustomers> createState() => _RecentCustomersState();
}

class _RecentCustomersState extends State<RecentCustomers> {
  TextEditingController searchcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Recent Customers',
            style: TextStyle(
              color: Color(0xffffffff),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 34,
                    itemBuilder: (context, index) {
                      return DashboardScreen();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
