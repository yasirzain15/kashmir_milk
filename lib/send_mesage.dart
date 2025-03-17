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

      // Debugging: Print values to check what's happening
      debugPrint("Price per Liter: ${customer.pricePerLiter}");
      debugPrint("Milk Quantity: ${customer.milkQuantity}");

      // Ensure values are valid
      double pricePerLiter =
          double.tryParse(customer.pricePerLiter?.toString() ?? "0") ?? 0;
      double quantityLiters =
          double.tryParse(customer.milkQuantity?.toString() ?? "0") ?? 0;

      // Validate extracted values
      if (pricePerLiter <= 0 || quantityLiters <= 0) {
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

      await launchUrl(smsUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }
}
