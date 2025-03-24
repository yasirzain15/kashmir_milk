import 'package:flutter/material.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  Map<String, int> skippedDaysMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff78c1f3),
        title: Text("Billing", style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<Funs>(
        builder: (context, funs, child) {
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: funs.customers.length,
            itemBuilder: (context, index) {
              Customer customer = funs.customers[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(customer.name ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Milk: ${customer.milkQuantity} Liters"),
                  trailing: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xff78c1f3)),
                    ),
                    onPressed: () => _showBillSheet(context, customer),
                    child: Text("Calculate Bill",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBillSheet(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int totalDays = 30;
            int skippedDays = skippedDaysMap[customer.name] ?? 0;
            int deliveredDays = totalDays - skippedDays;

            double totalBill = deliveredDays *
                (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
                (customer.pricePerLiter ?? 0);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Billing Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Customer: ${customer.name}"),
                  Text("Milk Quantity: ${customer.milkQuantity} Liters"),
                  Text("Price per Liter: Rs. ${customer.pricePerLiter}"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                          ),
                          onPressed: () {},
                          child: Text("Delivered: $deliveredDays",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () =>
                              _selectSkippedDays(context, customer, setState),
                          child: Text("Skipped: $skippedDays",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Total Bill: Rs. ${totalBill.toStringAsFixed(2)}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xff78c1f3)),
                          ),
                          onPressed: () => _generateAndSendSMS(
                              customer, deliveredDays, skippedDays, totalBill),
                          child: Text("Send SMS",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectSkippedDays(
      BuildContext context, Customer customer, Function setStateParent) async {
    List<DateTime> selectedDates = [];
    DateTime focusedDay = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Skipped Days"),
              content: SizedBox(
                height: 400,
                width: 350,
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => selectedDates.contains(day),
                  onDaySelected: (selectedDay, _) {
                    setState(() {
                      if (selectedDates.contains(selectedDay)) {
                        selectedDates.remove(selectedDay);
                      } else {
                        selectedDates.add(selectedDay);
                      }
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: Colors.blue, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setStateParent(() {
                      skippedDaysMap[customer.name ?? 'N/A'] =
                          selectedDates.length;
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getFormattedTime() {
    DateTime now = DateTime.now();
    int hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    int minute = now.minute;
    String amPm = now.hour >= 12 ? "PM" : "AM";

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm";
  }

  Future<void> _generateAndSendSMS(Customer customer, int deliveredDays,
      int skippedDays, double totalBill) async {
    String message = """
Billing Report:
Customer: ${customer.name}
Milk Quantity: ${customer.milkQuantity} Liters
Price per Liter: Rs. ${customer.pricePerLiter}

Delivered Days: $deliveredDays
Skipped Days: $skippedDays

Total Bill: Rs. ${totalBill.toStringAsFixed(2)}

Kindly Pay Your Bill on Time. Thank You!
EasyPaisa Number: 03143130462
Generated on: ${getFormattedTime()}
  """;

    String phoneNumber = customer.phoneNo ?? "";

    if (phoneNumber.isNotEmpty) {
      String smsUrl = "sms:$phoneNumber?body=${Uri.encodeComponent(message)}";

      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(Uri.parse(smsUrl));
      } else {
        print("Could not launch SMS app");
      }
    } else {
      print("Customer phone number is missing!");
    }
  }
}
