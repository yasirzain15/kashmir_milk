// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CsvUploader extends StatefulWidget {
  const CsvUploader({super.key});

  @override
  _CsvUploaderState createState() => _CsvUploaderState();
}

class _CsvUploaderState extends State<CsvUploader> {
  List<List<dynamic>> fileData = [];
  String? fileName;
  bool isUploading = false;
  bool isFileSelected = false;
  int uploadProgress = 0;

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
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
        String csvString = String.fromCharCodes(pickedFile.bytes!);

        List<List<dynamic>> csvTable =
            const CsvToListConverter().convert(csvString);

        setState(() {
          fileName = pickedFile.name;
          fileData = csvTable;
          isFileSelected = true;
        });
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not authenticated ❌"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      String userId = user.uid;
      CollectionReference userCollection =
          firestore.collection('users').doc(userId).collection('csv_data');

      List<String> headers = fileData[0].map((e) => e.toString()).toList();
      List<List<dynamic>> dataRows = fileData.sublist(1); // Skip headers

      int processedRows = 0;

      for (var row in dataRows) {
        String documentId = row[0].toString().trim().replaceAll(" ", "_");

        Map<String, dynamic> rowData = {};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          rowData[headers[j]] = row[j];
        }

        await userCollection.doc(documentId).set(rowData);

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
                  onPressed: isUploading ? null : pickFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text("Select CSV File 📂"),
                ),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : exportToFirebase,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(isUploading ? "Uploading..." : "Export 🚀"),
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
                            subtitle: Text(fileData[index].join(", ")),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text("No file selected."),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
