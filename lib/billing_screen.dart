import 'package:flutter/material.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  Map<String, List<DateTime>> skippedDaysMap = {};

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
    List<DateTime> skippedDays = skippedDaysMap[customer.name] ?? [];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int deliveredDays = 30 - skippedDays.length;
            double totalBill = deliveredDays *
                (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
                (customer.pricePerLiter ?? 0);

            return Padding(
              padding: EdgeInsets.all(16.0),
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
                  Text("Skipped Days: ${skippedDays.length}"),
                  ElevatedButton(
                    onPressed: () =>
                        _selectSkippedDays(context, customer, setState),
                    child: Text("Select Skipped Days"),
                  ),
                  SizedBox(height: 10),
                  Text("Total Bill: Rs. ${totalBill.toStringAsFixed(2)}"),
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
                                MaterialStateProperty.all(Colors.green),
                          ),
                          onPressed: () =>
                              _sendSMS(customer, totalBill, skippedDays.length),
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

  void _selectSkippedDays(
      BuildContext context, Customer customer, Function setState) {
    List<DateTime> selectedDays =
        List.from(skippedDaysMap[customer.name] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Select Skipped Days"),
              content: SizedBox(
                height: 300,
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: DateTime.now(),
                  selectedDayPredicate: (day) => selectedDays.contains(day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setDialogState(() {
                      if (selectedDays.contains(selectedDay)) {
                        selectedDays.remove(selectedDay);
                      } else {
                        selectedDays.add(selectedDay);
                      }
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      skippedDaysMap[customer.name ?? ""] = selectedDays;
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendSMS(
      Customer customer, double totalBill, int skippedDays) async {
    if (await Permission.sms.request().isGranted) {
      String message = """
Billing Report:
Customer: ${customer.name}
Skipped Days: $skippedDays
Total Bill: Rs. ${totalBill.toStringAsFixed(2)}
Pay Your Bill. Thank You!
""";
      try {
        await sendSMS(message: message, recipients: [customer.phoneNo ?? ""]);
      } catch (e) {
        print("SMS Sending Failed: $e");
      }
    } else {
      print("SMS Permission Denied!");
    }
  }
}
