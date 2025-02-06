// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference userCollection = firestore.collection('csv_data');

      int totalRows = fileData.length;
      int processedRows = 0;

      for (var row in fileData) {
        // Upload each row as a separate document
        await userCollection.add(row);
        processedRows++;

        // Update progress
        setState(() {
          uploadProgress = ((processedRows / totalRows) * 100).round();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully exported to Firebase ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting to Firebase ❌ $e"),
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
    );
  }
}
