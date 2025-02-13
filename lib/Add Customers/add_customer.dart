// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/dashboard.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:provider/provider.dart';

class CustomerRegistrationForm extends StatefulWidget {
  const CustomerRegistrationForm({super.key});

  @override
  _CustomerRegistrationFormState createState() =>
      _CustomerRegistrationFormState();
}

class _CustomerRegistrationFormState extends State<CustomerRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _milkQuantityController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double estimatedPrice = 0.0;
  final double pricePerLitre = 220.0;

  @override
  void initState() {
    super.initState();
    _milkQuantityController.addListener(_updateEstimatedPrice);
  }

  // Function to update estimated price dynamically
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _updateEstimatedPrice() {
    setState(() {
      double quantity = double.tryParse(_milkQuantityController.text) ?? 0.0;
      estimatedPrice = quantity * pricePerLitre;
    });
  }

  // Function to save customer data to Firestore
  Future<void> _saveCustomerData() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Phone Number are required!")),
      );
      return;
    }
    final customer = Customer(
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      sector: _sectorController.text.trim(),
      streetNo: _streetController.text.trim(),
      houseNo: _houseController.text.trim(),
      phoneNo: _phoneController.text.trim(),
      milkQuantity: _milkQuantityController.text.trim(),
      estimatedPrice: estimatedPrice,
      pricePerLiter: pricePerLitre,
    );
    final isConnected = await _checkInternetConnection();
    if (isConnected) {
      try {
        await _firestore.collection('customers').add({
          'Full Name': _nameController.text.trim(),
          'City': _cityController.text.trim(),
          'Sector': _sectorController.text.trim(),
          'Street No': _streetController.text.trim(),
          'House No': _houseController.text.trim(),
          'Phone No': _phoneController.text.trim(),
          'Milk Quantity': _milkQuantityController.text.trim(),
          'estimated_price': estimatedPrice,
          'Registration Time': FieldValue.serverTimestamp(),
          'Price/Liter': pricePerLitre,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer Added Successfully!")),
        );

        // Clear the fields after saving
        _nameController.clear();
        _cityController.clear();
        _sectorController.clear();
        _streetController.clear();
        _houseController.clear();
        _phoneController.clear();
        _milkQuantityController.clear();

        // Reset estimated price
        setState(() {
          estimatedPrice = 0.0;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      var box = Hive.box('customers');
      await box.add(customer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Internet! Saved Offline.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Customer Registration"),
      ),
      backgroundColor: Color(0xffffffff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Image Section (Ignored for now)

              const SizedBox(height: 90),

              // Form Fields
              _buildTextField(
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hint: "Full Name"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _cityController,
                  icon: Icons.location_city,
                  hint: "City"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _sectorController,
                  icon: Icons.business,
                  hint: "Sector"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _streetController,
                  icon: Icons.streetview,
                  hint: "Street No"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _houseController,
                  icon: Icons.home_outlined,
                  hint: "House No"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _phoneController,
                  icon: Icons.phone,
                  hint: "Phone Number"),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  controller: _milkQuantityController,
                  icon: Icons.water_drop_outlined,
                  hint: "Milk Quantity",
                  isNumber: true),

              // Price Information (Dynamic Estimated Price)
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price/L: 220 PKR",
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffafafbd),
                      ),
                    ),
                  ),
                  Text(
                    "Estimated: ${estimatedPrice.toStringAsFixed(2)} PKR",
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffafafbd),
                      ),
                    ),
                  ),
                ],
              ),

              // Add Customer Button
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () async {
                    await _saveCustomerData();
                    final provider = Provider.of<Funs>(context, listen: false);

                    provider.getall();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Add Customer",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required IconData icon,
      required String hint,
      bool isNumber = false}) {
    return Container(
      height: 51,
      width: 311,
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000).withOpacity(0.25),
            blurRadius: 9,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Color(0xffafafbd),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xffafafbd),
            ),
          ),
        ),
      ),
    );
  }
}
