// ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';

class CsvExcelUploader extends StatefulWidget {
  const CsvExcelUploader({super.key});

  @override
  _CsvExcelUploaderState createState() => _CsvExcelUploaderState();
}

class _CsvExcelUploaderState extends State<CsvExcelUploader> {
  List<Customer> fileData = []; // Ensure this holds valid data
  String? fileName;
  bool isUploading = false;
  int uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    await Hive.openBox<Map>('CSV_customers'); // Ensure box is open
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No file selected ❌"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      PlatformFile pickedFile = result.files.first;
      String csvString = utf8.decode(pickedFile.bytes!);
      fileName = pickedFile.name;

      List<List<dynamic>> csvTable =
          const CsvToListConverter(eol: '\n').convert(csvString);

      if (csvTable.isEmpty) throw Exception("CSV file is empty");

      List<String> headers =
          csvTable.first.map((e) => e.toString().trim()).toList();

      List<Customer> dataList = csvTable.skip(1).map((row) {
        var map = Map<String, dynamic>.fromIterables(headers, row.map((value) {
          // Convert numbers to string if needed
          return (value is double)
              ? value.toInt().toString()
              : value.toString();
        }));
        return Customer.fromJson(map);
      }).toList();

      setState(() {
        fileData = dataList;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File successfully loaded ✅"),
          backgroundColor: Color(0xff78c1f3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error reading CSV ❌ $e"),
          backgroundColor: Color(0xffff2c2c),
        ),
      );
    }
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> exportToStorage() async {
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
      bool hasInternet = await checkInternet();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('customer');

      int totalRows = fileData.length;
      int processedRows = 0;

      if (hasInternet) {
        for (var row in fileData) {
          final docref = userCollection.doc();
          await docref.set({...row.toJson(), "customer_id": docref.id});
          processedRows++;
          setState(() =>
              uploadProgress = ((processedRows / totalRows) * 100).round());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully exported to Firebase ✅"),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
      } else {
        var box = Hive.box<Map>('CSV_customers'); // Use proper type

        for (var row in fileData) {
          await box.add(row.toJson()); // Directly store the map

          processedRows++;
          print("Row saved: $row");

          if (processedRows % 5 == 0) {
            setState(() =>
                uploadProgress = ((processedRows / totalRows) * 100).round());
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved to Local Storage ❌ No Internet"),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error during upload ❌ $e"),
            backgroundColor: Color(0xffff2c2c)),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Color(0xff78c1f3),
          title: Text(
            "Upload CSV File",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: pickFile,
                child: buildButton(Icons.upload_file, "Upload File"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: exportToStorage,
                  child: buildButton(Icons.cloud_upload,
                      isUploading ? "Uploading..." : "Export File"),
                ),
              ),
              if (fileName != null) Text("Selected File: $fileName"),
              if (isUploading)
                LinearProgressIndicator(
                  value: uploadProgress / 100,
                  color: Color(0xff78c1f3),
                ),
              if (isUploading)
                Text("Upload Progress: $uploadProgress%",
                    style: TextStyle(
                      color: Color(0xff78c1f3),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(IconData icon, String text) {
    return Container(
      height: 45,
      width: 175,
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff78c1f3), Color(0xff78a2f3)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
