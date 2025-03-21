import 'package:flutter/material.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  Map<String, int> skippedDaysMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
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
                                MaterialStateProperty.all(Color(0xffff2c2c)),
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
                          onPressed: () => _generateAndSharePDF(
                              customer, deliveredDays, skippedDays, totalBill),
                          child: Text("Share Report",
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
    int hour =
        now.hour % 12 == 0 ? 12 : now.hour % 12; // Convert 0 to 12-hour format
    int minute = now.minute;
    String amPm = now.hour >= 12 ? "PM" : "AM";

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm";
  }

  Future<void> _generateAndSharePDF(Customer customer, int deliveredDays,
      int skippedDays, double totalBill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Billing Report",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Customer: ${customer.name}"),
            pw.Text("Milk Quantity: ${customer.milkQuantity} Liters"),
            pw.Text("Price per Liter: Rs. ${customer.pricePerLiter}"),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text("Delivered Days: $deliveredDays"),
                pw.SizedBox(width: 10),
                pw.Text("Skipped Days: $skippedDays"),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text("Total Bill: Rs. ${totalBill.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 50),
            pw.Text(
                "Dear ${customer.name}, Kindly Pay Your Bill on Time. Thank You!!!"),
            pw.SizedBox(height: 10),
            pw.Text('EasyPaisa Number: 03143130462'),
            pw.SizedBox(height: 35),
            pw.Text("Generated on: ${getFormattedTime()}"),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/bill_report.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)],
        text: "Billing Report for ${customer.name}");
  }
}
