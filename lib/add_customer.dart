import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    try {
      await _firestore.collection('customers').add({
        'name': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'sector': _sectorController.text.trim(),
        'street': _streetController.text.trim(),
        'house': _houseController.text.trim(),
        'phone': _phoneController.text.trim(),
        'milk_quantity': _milkQuantityController.text.trim(),
        'estimated_price': estimatedPrice,
        'timestamp': FieldValue.serverTimestamp(),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Image Section (Ignored for now)
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 30),

              // Form Fields
              _buildTextField(
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hint: "Full Name"),
              _buildTextField(
                  controller: _cityController,
                  icon: Icons.location_city,
                  hint: "City"),
              _buildTextField(
                  controller: _sectorController,
                  icon: Icons.business,
                  hint: "Sector"),
              _buildTextField(
                  controller: _streetController,
                  icon: Icons.streetview,
                  hint: "Street No"),
              _buildTextField(
                  controller: _houseController,
                  icon: Icons.home_outlined,
                  hint: "House No"),
              _buildTextField(
                  controller: _phoneController,
                  icon: Icons.phone,
                  hint: "Phone Number"),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "Estimated: ${estimatedPrice.toStringAsFixed(2)} PKR",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
                  onPressed: _saveCustomerData,
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
      margin: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
