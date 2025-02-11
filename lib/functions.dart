import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Funs extends ChangeNotifier {
  List<Map<String, dynamic>> customers = [];
  Future<void> getall() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollection = firestore.collection('customers');
      final response = await userCollection.get();

      customers = response.docs.map((customer) {
        return customer.data() as Map<String, dynamic>;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }
}
