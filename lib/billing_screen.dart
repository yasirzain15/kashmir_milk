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
        title:
            Text("Billing Details", style: TextStyle(color: Color(0xffffffff))),
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
                          subtitle:
                              Text("Milk: ${customer.milkQuantity} Liters"),
                          trailing: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff78c1f3), Color(0xff78a2f3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: () =>
                                  _showBillSheet(context, customer),
                              child: Text(
                                "Calculate Bill",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send, color: Colors.white),
                    label: Text('Send to All',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff78c1f3),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showSendToAllSheet(context),
                  ),
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
        return BillingDetails(
            customer: customer, skippedDaysMap: skippedDaysMap);
      },
    );
  }

  void _showSendToAllSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Consumer<Funs>(
          builder: (context, funs, child) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return SendToAllSheet(
                  customers: funs.customers,
                  skippedDaysMap: skippedDaysMap,
                );
              },
            );
          },
        );
      },
    );
  }
}

class SendToAllSheet extends StatefulWidget {
  final List<Customer> customers;
  final Map<String, List<DateTime>> skippedDaysMap;

  const SendToAllSheet({
    required this.customers,
    required this.skippedDaysMap,
    Key? key,
  }) : super(key: key);

  @override
  _SendToAllSheetState createState() => _SendToAllSheetState();
}

class _SendToAllSheetState extends State<SendToAllSheet> {
  Map<String, List<DateTime>> selectedSkippedDaysMap = {};
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    selectedSkippedDaysMap = Map.from(widget.skippedDaysMap);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Bulk SMS to All Customers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Select skipped days for each customer:",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.customers.length,
              itemBuilder: (context, index) {
                final customer = widget.customers[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              customer.name ?? 'Unknown',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                "${selectedSkippedDaysMap[customer.name]?.length ?? 0} skipped days",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Color(0xff78c1f3),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78c1f3),
                              ),
                              onPressed: () =>
                                  _showCalendarForCustomer(customer),
                              child: Text("Select Days",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: isSending ? null : () => _sendSmsToAll(),
            child: isSending
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Send SMS to All Customers",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: isSending ? null : () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCalendarForCustomer(Customer customer) {
    DateTime _focusedDay = DateTime.now();
    List<DateTime> selectedDays =
        List.from(selectedSkippedDaysMap[customer.name] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Skipped Days for ${customer.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 400,
                    width: 350,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return selectedDays.any((d) =>
                            d.year == day.year &&
                            d.month == day.month &&
                            d.day == day.day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (selectedDays.any((d) =>
                              d.year == selectedDay.year &&
                              d.month == selectedDay.month &&
                              d.day == selectedDay.day)) {
                            selectedDays.removeWhere((d) =>
                                d.year == selectedDay.year &&
                                d.month == selectedDay.month &&
                                d.day == selectedDay.day);
                          } else {
                            selectedDays.add(selectedDay);
                          }
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedSkippedDaysMap[customer.name ?? ""] =
                          selectedDays;
                      widget.skippedDaysMap[customer.name ?? ""] = selectedDays;
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

  Future<void> _sendSmsToAll() async {
    setState(() => isSending = true);

    final status = await Permission.sms.request();
    if (status.isGranted) {
      int successCount = 0;
      int failCount = 0;
      List<String> failedCustomers = [];

      for (var customer in widget.customers) {
        final skippedDays = selectedSkippedDaysMap[customer.name]?.length ?? 0;
        final deliveredDays = 30 - skippedDays;
        final totalBill = deliveredDays *
            (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
            (customer.pricePerLiter ?? 0);

        String message = """
Billing Report:
Customer: ${customer.name}
Delivered Days: $deliveredDays
Skipped Days: $skippedDays
Total Bill: Rs. ${totalBill.toStringAsFixed(2)}
Please Pay Your Bill. Thank You!
""";

        if (customer.phoneNo != null && customer.phoneNo!.isNotEmpty) {
          try {
            String result = await sendSMS(
              message: message,
              recipients: [customer.phoneNo!],
              sendDirect: true,
            );
            if (result.contains("sent")) {
              successCount++;
            } else {
              failCount++;
              failedCustomers.add(customer.name ?? "Unknown");
            }
            await Future.delayed(Duration(milliseconds: 500));
          } catch (e) {
            failCount++;
            failedCustomers.add(customer.name ?? "Unknown");
            print("Failed to send SMS to ${customer.name}: $e");
          }
        } else {
          failCount++;
          failedCustomers.add(customer.name ?? "Unknown");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sent $successCount messages. Failed: $failCount"),
          duration: Duration(seconds: 3),
        ),
      );

      if (failedCustomers.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text("Succesfully sent to ${failedCustomers.length} customers"),
            content: SingleChildScrollView(
                // child: Column(
                //   children: failedCustomers.map((name) => Text(name)).toList(),
                // ),
                ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission denied")),
      );
    }

    setState(() => isSending = false);
  }
}

class BillingDetails extends StatefulWidget {
  final Customer customer;
  final Map<String, List<DateTime>> skippedDaysMap;

  BillingDetails({required this.customer, required this.skippedDaysMap});

  @override
  _BillingDetailsState createState() => _BillingDetailsState();
}

class _BillingDetailsState extends State<BillingDetails> {
  List<DateTime> selectedSkippedDays = [];
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    selectedSkippedDays =
        List.from(widget.skippedDaysMap[widget.customer.name] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    int skippedDays = selectedSkippedDays.length;
    int deliveredDays = 30 - skippedDays;
    double totalBill = deliveredDays *
        (double.tryParse(widget.customer.milkQuantity ?? '0') ?? 0) *
        (widget.customer.pricePerLiter ?? 0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Billing Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Customer: ${widget.customer.name}"),
          Text("Milk Quantity: ${widget.customer.milkQuantity} Liters"),
          Text("Price per Liter: Rs. ${widget.customer.pricePerLiter}"),
          SizedBox(height: 10),
          Text("Skipped Days: $skippedDays"),
          Text("Delivered Days: $deliveredDays"),
          ElevatedButton(
            onPressed: () => _selectSkippedDays(context),
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
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  onPressed: isSending ? null : () => _sendSMS(),
                  child: isSending
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Send SMS", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectSkippedDays(BuildContext context) {
    DateTime _focusedDay = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Skipped Days"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 400,
                    width: 350,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return selectedSkippedDays.any((d) =>
                            d.year == day.year &&
                            d.month == day.month &&
                            d.day == day.day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (selectedSkippedDays.any((d) =>
                              d.year == selectedDay.year &&
                              d.month == selectedDay.month &&
                              d.day == selectedDay.day)) {
                            selectedSkippedDays.removeWhere((d) =>
                                d.year == selectedDay.year &&
                                d.month == selectedDay.month &&
                                d.day == selectedDay.day);
                          } else {
                            selectedSkippedDays.add(selectedDay);
                          }
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.skippedDaysMap[widget.customer.name ?? ""] =
                          List.from(selectedSkippedDays);
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

  Future<void> _sendSMS() async {
    setState(() => isSending = true);

    final status = await Permission.sms.request();
    if (status.isGranted) {
      int skippedDays = selectedSkippedDays.length;
      int deliveredDays = 30 - skippedDays;
      double totalBill = deliveredDays *
          (double.tryParse(widget.customer.milkQuantity ?? '0') ?? 0) *
          (widget.customer.pricePerLiter ?? 0);

      String message = """
Billing Report:
Customer: ${widget.customer.name}
Delivered Days: $deliveredDays
Skipped Days: $skippedDays
Total Bill: Rs. ${totalBill.toStringAsFixed(2)}
Please Pay Your Bill. Thank You!

""";

      try {
        String result = await sendSMS(
          message: message,
          recipients: [widget.customer.phoneNo ?? ""],
          sendDirect: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result.contains("sent") ? "Message sent successfully" : ""),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission denied")),
      );
    }

    setState(() => isSending = false);
  }
}
