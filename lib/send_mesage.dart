// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMessage {
  void sendMessage(Customer customer, BuildContext context) async {
    try {
      String customerName = customer.name ?? "Customer";
      String phoneNumber = customer.phoneNo?.toString().trim() ?? "";

      // Validate phone number
      if (phoneNumber.isEmpty || phoneNumber.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid phone number for $customerName"),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
        return;
      }

      // Ensure phone number contains only digits
      if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid phone number format for $customerName"),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      // Parsing numerical values safely
      double? pricePerLiter =
          double.tryParse(customer.pricePerLiter?.toString() ?? "0");
      double? quantityLiters =
          double.tryParse(customer.milkQuantity?.toString() ?? "0");

      if (pricePerLiter == null ||
          quantityLiters == null ||
          pricePerLiter <= 0 ||
          quantityLiters <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                "Bill calculation error for $customerName. Please check the data.",
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xff78c1f3)),
        );
        return;
      }

      double totalBill = pricePerLiter * quantityLiters;

      String message =
          "Hello $customerName, your total milk bill is Rs. ${totalBill.toStringAsFixed(2)} "
          "(Price: Rs. ${pricePerLiter.toStringAsFixed(2)}/L x ${quantityLiters.toStringAsFixed(2)}L). "
          "Please make the payment soon. Thank you!  EasyPaisa Number : 03143130462";

      Uri smsUri =
          Uri.parse("sms:$phoneNumber?body=${Uri.encodeComponent(message)}");

      // Check if device can launch SMS app
      // if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.platformDefault);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //         content: Text(
      //             "Could not open messaging app. Ensure an SMS app is installed."),
      // duration: Duration(seconds: 1),),
      //   );
      // }
    } catch (e) {
      addSub(4, 6);
      debugPrint("Error sending message: $e");
    }
  }
}

int addSub(int x, int y) {
  return x + y;
}
