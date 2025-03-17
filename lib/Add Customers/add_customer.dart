// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks, deprecated_member_use

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:kashmeer_milk/Authentication/auth_ser.dart';
import 'package:kashmeer_milk/dashboard.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class CustomerRegistrationForm extends StatefulWidget {
  final Customer? customer;

  const CustomerRegistrationForm({super.key, this.customer});

  @override
  // ignore: library_private_types_in_public_api
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
  late String customerId = const Uuid().v1();

  double estimatedPrice = 0.0;
  final double pricePerLitre = 220.0;
  bool isLoading = false;

  bool? isConnected;

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    customerId =
        widget.customer?.customerId ?? const Uuid().v1().replaceAll("-", "");
    _nameController.text = widget.customer?.name ?? '';
    _cityController.text = widget.customer?.city ?? '';
    _sectorController.text = widget.customer?.sector ?? '';
    _streetController.text = widget.customer?.streetNo ?? '';
    _houseController.text = widget.customer?.houseNo ?? '';
    _phoneController.text = widget.customer?.phoneNo ?? '';
    _milkQuantityController.text = widget.customer?.milkQuantity ?? '';
    _milkQuantityController.addListener(_updateEstimatedPrice);
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Check if the device is connected to WiFi or Mobile Data
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet Connection"),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xff78c1f3),
        ),
      );
      return false;
    }

    // Try pinging Google to check actual internet access
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5)); // Timeout after 5 seconds

      if (response.statusCode == 200) {
        return true; // Internet is working
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Internet: Failed to reach server"),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xff78c1f3),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet: Saved Offline !!"),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xffc30010),
        ),
      );
      return false;
    }
  }

  Future<void> updateCustomerData(
      Customer customer, BuildContext context) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update the customer document in Firestore
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('customer')
          .doc(customer.customerId)
          .set(customer.toJson());

      // Update the customer data in Hive
      final box = Hive.box<Customer>('customers');

      final keyToUpdate = box.keys.firstWhere(
        (key) => box.get(key)?.customerId == customer.customerId,
        orElse: () => null,
      );

      if (keyToUpdate != null) {
        await box.put(keyToUpdate, customer);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer Updated Successfully! ✅"),
          backgroundColor: Color(0xff78c1f3),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update customer: ${e.toString()} ❌"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateEstimatedPrice() {
    setState(() {
      double quantity = double.tryParse(_milkQuantityController.text) ?? 0.0;
      estimatedPrice = quantity * pricePerLitre;
    });
  }

  // Function to save customer data to Firestore
  Future<void> _saveCustomerData() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
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
      pricePerLiter: pricePerLitre,
      customerId: customerId,
    );

    isConnected = await _checkInternetConnection();

    if (isConnected!) {
      try {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('customer')
            .doc(customerId)
            .set(customer.toJson(), SetOptions(merge: true));

        // Refresh the customer list in the provider
        await Provider.of<Funs>(context, listen: false).getall();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer Added/Updated Successfully!"),
            backgroundColor: Color(0xff78c1f3),
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          estimatedPrice = 0.0;
        });

        // Navigate back to the dashboard
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      var box = Hive.box<Customer>('customers');
      await box.add(customer);

      // Refresh the customer list in the provider
      await Provider.of<Funs>(context, listen: false).getFromHive();

      _nameController.clear();
      _cityController.clear();
      _sectorController.clear();
      _streetController.clear();
      _houseController.clear();
      _phoneController.clear();
      _milkQuantityController.clear();

      // Navigate back to the dashboard
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Color(0xff78c1f3),
              title: Text(
                widget.customer == null
                    ? 'Customer Registration'
                    : 'Update Customer',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            backgroundColor: Color(0xffffffff),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Assign the form key
                  child: Column(
                    children: [
                      const SizedBox(height: 90),

                      // Form Fields
                      _buildTextField(
                          controller: _nameController,
                          icon: Icons.person_outline,
                          hint: "Full Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _cityController,
                          icon: Icons.location_city,
                          hint: "City",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "City is required";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _sectorController,
                          icon: Icons.business,
                          hint: "Sector",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Sector is required";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _streetController,
                          icon: Icons.streetview,
                          hint: "Street No",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Street No is required";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _houseController,
                          icon: Icons.home_outlined,
                          hint: "House No",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "House No is required";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _phoneController,
                          icon: Icons.phone,
                          hint: "Phone Number",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone Number is required";
                            }
                            if (value.length != 11) {
                              return "Phone Number must be 11 digits";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _milkQuantityController,
                          icon: Icons.water_drop_outlined,
                          hint: "Milk Quantity",
                          isNumber: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Milk Quantity is required";
                            }
                            if (double.tryParse(value) == null) {
                              return "Invalid quantity";
                            }
                            return null;
                          }),

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
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff78c1f3),
                              Color(0xff78a2f3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              if (_formKey.currentState!.validate()) {
                                final updatedCustomer = Customer(
                                  name: _nameController.text.trim(),
                                  city: _cityController.text.trim(),
                                  sector: _sectorController.text.trim(),
                                  streetNo: _streetController.text.trim(),
                                  houseNo: _houseController.text.trim(),
                                  phoneNo: _phoneController.text.trim(),
                                  milkQuantity:
                                      _milkQuantityController.text.trim(),
                                  pricePerLiter: pricePerLitre,
                                  customerId: customerId,
                                );
                                if (widget.customer != null) {
                                  // If updating an existing customer
                                  await updateCustomerData(
                                      updatedCustomer, context);
                                } else {
                                  // If adding a new customer
                                  await _saveCustomerData();
                                }

                                final provider =
                                    Provider.of<Funs>(context, listen: false);

                                if (isConnected ?? false) {
                                  // Handle null safety
                                  await provider
                                      .getall(); // Fetch from Firebase if online
                                } else {}

                                // Navigate back after saving data
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Failed to save/Update customer. Please try again.")));
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: Text(
                            widget.customer == null
                                ? 'Add Customer'
                                : 'Update Customer',
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
            ),
          ),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Color(0xff78c1f3))) // Show Loader
            : Container()
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      // height: 51,
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
      child: TextFormField(
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
        validator: validator,
      ),
    );
  }
}
