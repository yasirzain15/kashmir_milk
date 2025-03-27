import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/customerdetail_screen.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';

class SeeallScreen extends StatefulWidget {
  const SeeallScreen({super.key});

  @override
  State<SeeallScreen> createState() => _SeeallScreenState();
}

class _SeeallScreenState extends State<SeeallScreen> {
  List<Customer> customers = [];
  String _searchQuery = "";
  Map<String, List<DateTime>> skippedDaysMap = {};

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    List<Customer> hiveCustomers = _getCustomersFromHive();
    List<Customer> firestoreCustomers = await _getCustomersFromFirestore();

    setState(() {
      customers = [...hiveCustomers, ...firestoreCustomers];
    });
  }

  List<Customer> _getCustomersFromHive() {
    final box = Hive.box<Customer>('customers');
    return box.values.toList();
  }

  Future<List<Customer>> _getCustomersFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customer')
          .get();

      return snapshot.docs
          .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching Firestore data: $e");
      return [];
    }
  }

  List<Customer> _filterCustomers(List<Customer> customers, String query) {
    if (query.isEmpty) {
      return customers;
    }
    return customers.where((customer) {
      final name = customer.name?.toString().toLowerCase() ?? "";
      final city = customer.city?.toString().toLowerCase() ?? "";
      final phone = customer.phoneNo?.toString().toLowerCase() ?? "";
      return name.contains(query.toLowerCase()) ||
          city.contains(query.toLowerCase()) ||
          phone.contains(query.toLowerCase());
    }).toList();
  }

  Future<void> _showSkippedDaysDialog(Customer customer) async {
    List<DateTime> selectedDays =
        List.from(skippedDaysMap[customer.name] ?? []);
    DateTime focusedDay = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Skipped Days for ${customer.name}"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) {
                    return selectedDays.any((selectedDay) =>
                        selectedDay.year == day.year &&
                        selectedDay.month == day.month &&
                        selectedDay.day == day.day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (selectedDays.any((day) =>
                          day.year == selectedDay.year &&
                          day.month == selectedDay.month &&
                          day.day == selectedDay.day)) {
                        selectedDays.removeWhere((day) =>
                            day.year == selectedDay.year &&
                            day.month == selectedDay.month &&
                            day.day == selectedDay.day);
                      } else {
                        selectedDays.add(selectedDay);
                      }
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      skippedDaysMap[customer.name ?? ""] = selectedDays;
                    });
                    _sendMonthlyReport(customer, selectedDays);
                    Navigator.pop(context);
                  },
                  child: const Text("Send Report"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendMonthlyReport(
      Customer customer, List<DateTime> skippedDays) async {
    if (await Permission.sms.request().isGranted) {
      try {
        int deliveredDays = 30 - skippedDays.length;
        double totalBill = deliveredDays *
            (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
            (customer.pricePerLiter ?? 0);

        String message = """
Monthly Milk Report for ${customer.name}:
------------------------------
Milk Quantity: ${customer.milkQuantity} liters
Price per Liter: Rs. ${customer.pricePerLiter}
Delivered Days: $deliveredDays
Skipped Days: ${skippedDays.length}
Total Bill: Rs. ${totalBill.toStringAsFixed(2)}
------------------------------
Please make the payment at your earliest convenience.
Thank you for your business!
""";

        await sendSMS(
          message: message,
          recipients: [customer.phoneNo ?? ""],
          sendDirect: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Report sent to ${customer.name}"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send report: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SMS permission denied"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _filterCustomers(customers, _searchQuery);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff78c1f3),
          title: Text(
            "Customers Reports",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
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
                  filled: true,
                  fillColor: const Color(0x2bc5e0f2),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: filteredCustomers.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff78c1f3),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return buildCustomerItem(filteredCustomers[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerItem(Customer customer) {
    String name = customer.name ?? "Unknown";
    String city = customer.city ?? "Unknown City";
    String address = [customer.houseNo, customer.streetNo, customer.sector]
        .where((element) => element != null && element.toString().isNotEmpty)
        .join(", ");
    String phone = customer.phoneNo?.toString() ?? "N/A";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailScreen(
              customer: customer,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
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
                      name,
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
                      address.isEmpty ? "No Address Provided" : address,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "City: $city",
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
                      "Phone: $phone",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Milk Quantity: ${customer.milkQuantity ?? "Unknown"}",
                      style: const TextStyle(
                        color: Color(0xff78c1f3),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: () => _showSkippedDaysDialog(customer),
                        child: Container(
                          width: 300,
                          height: 36.53,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff78c1f3),
                                Color(0xff78a2f3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Send Monthly Report',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
        ),
      ),
    );
  }
}
