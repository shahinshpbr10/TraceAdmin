import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final _formKey = GlobalKey<FormState>();
  File? _busImage;
  final _nameController = TextEditingController();
  final _routeController = TextEditingController();
  final _numberPlateController = TextEditingController();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Image Picker
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _busImage = File(pickedFile.path);
      });
    }
  }

  // Upload Image to Firebase Storage
  Future<String?> _uploadBusImage() async {
    if (_busImage == null) return null;
    try {
      String fileName = const Uuid().v4();
      Reference ref = _storage.ref().child('buses/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(_busImage!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("🔥 Image upload error: $e");
      return null;
    }
  }

  // Submit Form & Save Bus to Firestore
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? busImageUrl = await _uploadBusImage();

    Map<String, dynamic> busData = {
      "name": _nameController.text.trim(),
      "route": _routeController.text.trim(),
      "numberPlate": _numberPlateController.text.trim(),
      "imageUrl": busImageUrl ?? "",
      "createdAt": FieldValue.serverTimestamp(), // Timestamp for sorting
    };

    try {
      await _firestore.collection("buses").add(busData);
      setState(() => _isLoading = false);

      print("✅ Bus added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bus added successfully!"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Firestore error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding bus: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bus"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Bus Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _busImage != null ? FileImage(_busImage!) : null,
                      child: _busImage == null
                          ? const Icon(Icons.camera_alt, size: 35, color: Colors.grey)
                          : null,
                    ),
                    if (_busImage != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 20, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Bus Name", Icons.directions_bus),
              const SizedBox(height: 15),

              _buildTextField(_routeController, "Route Number", Icons.route),
              const SizedBox(height: 15),

              _buildTextField(_numberPlateController, "Number Plate", Icons.confirmation_number),
              const SizedBox(height: 20),

              // Submit Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
      ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Please enter $label" : null,
    );
  }
}
