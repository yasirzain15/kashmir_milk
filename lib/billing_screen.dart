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

class BillingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
          backgroundColor: Color(0xff78c1f3),
          title: Text(
            "Billing",
            style: TextStyle(
              color: Color(0xffffffff),
            ),
          )),
      body: Consumer<Funs>(
        builder: (context, funs, child) {
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: funs.customers.length,
            itemBuilder: (context, index) {
              Customer customer = funs.customers[index];
              return Card(
                color: Color(0xffffffff),
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
                    child: Text(
                      "Calculate Bill",
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
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
    double totalBill = (double.tryParse(customer.milkQuantity ?? '0') ?? 0) *
        (customer.pricePerLiter ?? 0);
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
              Text(
                "Billing Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Customer: ${customer.name}"),
              Text("Milk Quantity: ${customer.milkQuantity} Liters"),
              Text("Price per Liter: Rs. ${customer.pricePerLiter}"),
              SizedBox(height: 10),
              Text(
                "Total Bill: Rs. ${totalBill.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                      child: Text(
                        "Close",
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff78c1f3)),
                      ),
                      onPressed: () =>
                          _generateAndSharePDF(customer, totalBill),
                      child: Text(
                        "Share Report",
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAndSharePDF(Customer customer, double totalBill) async {
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
            pw.Text(
              "Total Bill: Rs. ${totalBill.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Dear ${customer.name} Kindly Pay Your Bill on Time \nThank You \nEasyPaisa Number:03143130462\n ${DateTime.now()}'),
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
