// ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, unused_element

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:kashmeer_milk/Models/customer_model.dart';

class CsvExcelUploader extends StatefulWidget {
  const CsvExcelUploader({super.key});

  @override
  _CsvExcelUploaderState createState() => _CsvExcelUploaderState();
}

class _CsvExcelUploaderState extends State<CsvExcelUploader> {
  List<Map<String, dynamic>?> fileData = [];
  String? fileName;
  bool isUploading = false;
  int uploadProgress = 0;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No file selected ❌"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      PlatformFile pickedFile = result.files.first;
      String csvString = utf8.decode(pickedFile.bytes!);
      fileName = pickedFile.name;

      print("CSV content: $csvString");

      List<List<dynamic>> csvTable =
          const CsvToListConverter(eol: '\n').convert(csvString);

      if (csvTable.isEmpty) throw Exception("CSV file is empty");

      print("CSV Table: $csvTable");

      List<String> headers =
          csvTable.first.map((e) => e.toString().trim()).toList();
      List<Map<String, dynamic>?> dataList = csvTable
          .skip(1)
          .map((row) {
            if (row.length != headers.length) {
              print("Skipping row due to incorrect column count: $row");
              return null;
            }
            return Map<String, dynamic>.fromIterables(headers, row);
          })
          .where((element) => element != null)
          .toList();

      print("Parsed data: $dataList");

      setState(() {
        fileData = dataList;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("File successfully loaded ✅"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error reading CSV ❌ $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Check if the device is connected to WiFi or Mobile Data
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Internet Connection")),
      );
      return false;
    }

    // Try pinging Google to check actual internet access
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5)); // Timeout after 5 seconds

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Internet Connected via ${connectivityResult == ConnectivityResult.wifi ? "WiFi" : "Mobile Data"}")),
        );
        return true; // Internet is working
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Internet: Failed to reach server")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Internet: Unable to connect")),
      );
      return false;
    }
  }

  Future<void> exportToFirebase() async {
    if (fileData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No data to upload ❌"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {
      int totalRows = fileData.length;
      int processedRows = 0;
      final isConnected = await _checkInternetConnection();

      if (isConnected) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        CollectionReference userCollection = firestore.collection('csv_data');

        for (var row in fileData) {
          // Upload each row as a separate document
          await userCollection.add(row);
          processedRows++;
        }

        // Update progress
        setState(() {
          uploadProgress = ((processedRows / totalRows) * 100).round();
        });
      } else {
        var box = Hive.box<Customer>('CSV customers');

        for (var row in fileData) {
          await box.add(Customer.fromJson(row!));

          // Upload each row as a separate document

          processedRows++;
        }
        // Update progress
        setState(() {
          uploadProgress = ((processedRows / totalRows) * 100).round();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully exported to Local Storage"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting to Local Storage ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CSV Uploader to Firestore 📂")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.file_upload),
                label: const Text("Select CSV File 📂"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: exportToFirebase,
                icon: const Icon(Icons.cloud_upload),
                label: Text(isUploading ? "Exporting..." : "Export 🚀"),
              ),
              const SizedBox(height: 20),
              if (fileName != null) ...[
                Text("Selected File: $fileName"),
                if (isUploading)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: uploadProgress / 100),
                      Text("Upload Progress: $uploadProgress%"),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
