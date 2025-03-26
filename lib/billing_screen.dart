import 'package:flutter/material.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'dart:async';

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
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.redAccent),
                  ),
                  onPressed: () => _showBillingDetailsForAll(context),
                  child: Text("Send to All",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Billing Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Customer: ${customer.name}"),
              Text("Milk Quantity: ${customer.milkQuantity} Liters"),
              Text("Price per Liter: Rs. ${customer.pricePerLiter}"),
              SizedBox(height: 10),
              Text(
                  "Total Bill: Rs. ${(30 - (skippedDaysMap[customer.name] ?? 0)) * (double.tryParse(customer.milkQuantity ?? '0') ?? 0) * (customer.pricePerLiter ?? 0)}"),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text("Close", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBillingDetailsForAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Billing Details for All"),
          content: Text("Select skipped days, then send SMS to all customers."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sendSMSToAllCustomers();
              },
              child: Text("Send SMS"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSMSToAllCustomers() async {
    var funs = Provider.of<Funs>(context, listen: false);
    for (int i = 0; i < funs.customers.length; i++) {
      Customer customer = funs.customers[i];
      int skippedDays = skippedDaysMap[customer.name] ?? 0;
      int deliveredDays = 30 - skippedDays;
      double totalBill = deliveredDays *
          (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
          (customer.pricePerLiter ?? 0);

      _sendSMS(customer, deliveredDays, skippedDays, totalBill);

      await Future.delayed(Duration(seconds: 4));
    }
  }

  void _sendSMS(
      Customer customer, int deliveredDays, int skippedDays, double totalBill) {
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
""";

    String phoneNumber = customer.phoneNo ?? "";

    if (phoneNumber.isNotEmpty) {
      sendSMS(message: message, recipients: [phoneNumber]);
    } else {
      print("Customer phone number is missing!");
    }
  }
}
