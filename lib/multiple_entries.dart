// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CsvExcelUploader extends StatefulWidget {
  const CsvExcelUploader({super.key});

  @override
  _CsvExcelUploaderState createState() => _CsvExcelUploaderState();
}

class _CsvExcelUploaderState extends State<CsvExcelUploader> {
  List<Map<String, dynamic>> fileData = [];
  String? fileName;
  PlatformFile? file;
  String? fileType;
  bool isUploading = false;
  bool isFileSelected = false;
  int uploadProgress = 0;

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.audio.isGranted) {
        return true;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.storage,
        Permission.audio,
      ].request();

      if (statuses[Permission.storage]!.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission is required ❌"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> readCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Ensures the file data is loaded
      );

      if (result == null || result.files.isEmpty) {
        throw Exception("No file selected");
      }

      PlatformFile pickedFile = result.files.first;
      String csvString = utf8.decode(pickedFile.bytes!);
      fileName = pickedFile.name;
      fileType = pickedFile.extension;
      file = pickedFile;

      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty) {
        throw Exception("CSV file is empty");
      }

      List<String> headers = csvTable[0].map((e) => e.toString()).toList();
      List<List<dynamic>> dataRows = csvTable.sublist(1); // Skip headers

      List<Map<String, dynamic>> dataList = dataRows.map((row) {
        if (row.length != headers.length) {
          throw Exception(
              "Invalid row length. Expected ${headers.length}, got ${row.length}");
        }

        return Map.fromIterables(headers, row);
      }).toList();

      return dataList;
    } catch (e) {
      print("Error reading CSV: $e");
      return [];
    }
  }

  Future<void> pickFile() async {
    bool permissionGranted = await _requestPermissions();
    if (!permissionGranted) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile pickedFile = result.files.first;

        if (pickedFile.extension == "csv") {
          setState(() {
            file = pickedFile;
            fileName = pickedFile.name;
            fileType = pickedFile.extension;
            isFileSelected = true;
          });
        } else {
          throw Exception("Unsupported file format: ${pickedFile.extension}");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No file selected ❌"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selecting file ❌ $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> exportToFirebase() async {
    if (file == null) {
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

      // Get headers from the first row
      List<String> headers = fileData.map((e) => e.toString()).toList();
      List<dynamic> dataRows = fileData.sublist(1); // Remove header row
      int processedRows = 0;

      for (var row in dataRows) {
        // Here, we use the user's Name (column 0) as the document ID.
        String documentId = row[0]
            .toString()
            .trim()
            .replaceAll(" ", "_"); // Assuming 'Name' is in column 0

        // Generate a reference to the user's document using their unique documentId
        DocumentReference docRef =
            firestore.collection('csv_data').doc(documentId);

        Map<String, dynamic> rowData = {};

        // Add data for each column
        for (int j = 0; j < headers.length && j < row.length; j++) {
          var value = row[j];
          if (value is String) {
            // Try to convert numeric strings to numbers
            double? numValue = double.tryParse(value);
            rowData[headers[j]] = numValue ?? value;
          } else {
            rowData[headers[j]] = value;
          }
        }

        // Set data for the user's document
        await docRef.set(rowData);

        processedRows++;

        setState(() {
          uploadProgress = ((processedRows / dataRows.length) * 100).round();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully exported to Firebase ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error exporting to Firebase ❌ $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSV Uploader to Firestore 📂"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    fileData = await readCsvFile();
                  },
                  icon: const Icon(Icons.file_upload),
                  label: const Text("Select CSV File 📂"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: ElevatedButton.icon(
                    onPressed: () => exportToFirebase(),
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      isUploading ? "Exporting..." : "Export 🚀",
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (fileName != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Selected File: $fileName",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Type: ${fileType?.toUpperCase() ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (isUploading) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: uploadProgress / 100),
                        Text("Upload Progress: $uploadProgress%"),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: fileData.isNotEmpty
                  ? Card(
                      child: ListView.builder(
                        itemCount: fileData.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              index == 0 ? "Headers" : "Row $index",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "",
                              style: TextStyle(
                                color: index == 0 ? Colors.blue : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
