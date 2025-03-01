import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  File? _profilePic;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _workerType = 'Driver'; // Default worker type
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String? _adminId; // Current logged-in admin ID

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch current logged-in admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid; // Admin ID = Current User ID
      });
    }
  }

  // ✅ Image Picker
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePic = File(pickedFile.path);
      });
    }
  }

  // ✅ Upload Image to Firebase Storage
  Future<String?> _uploadProfilePic() async {
    if (_profilePic == null) return null;
    try {
      String fileName = const Uuid().v4();
      Reference ref = _storage.ref().child('workers/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(_profilePic!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("🔥 Image upload error: $e");
      return null;
    }
  }

  // ✅ Submit Form & Save Worker inside "admins/{adminId}/workers" sub-collection
  Future<void> _submitForm() async {
    if (_adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin ID not found!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? profilePicUrl = await _uploadProfilePic();

    // Create worker data
    Map<String, dynamic> workerData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "workerType": _workerType,
      "profilePicUrl": profilePicUrl ?? "",
      "createdAt": FieldValue.serverTimestamp(), // Timestamp for sorting
    };

    try {
      // ✅ Store worker inside "admins/{adminId}/workers" sub-collection
      DocumentReference docRef = await _firestore
          .collection("admins")
          .doc(_adminId) // 🔥 Stores under current admin
          .collection("workers")
          .add(workerData);

      print("✅ Worker added with ID: ${docRef.id}");

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker added successfully!"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Firestore error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding worker: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Worker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ Profile Picture Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
                      child: _profilePic == null
                          ? const Icon(Icons.camera_alt, size: 35, color: Colors.grey)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Name", Icons.person),
              const SizedBox(height: 15),

              _buildTextField(_emailController, "Email", Icons.email, TextInputType.emailAddress),
              const SizedBox(height: 15),

              _buildTextField(_phoneController, "Phone Number", Icons.phone, TextInputType.phone),
              const SizedBox(height: 15),

              // ✅ Worker Type Dropdown
              _buildDropdownField(
                label: "Worker Type",
                icon: Icons.work,
                value: _workerType,
                items: ['Driver', 'Conductor', 'Helper'],
                onChanged: (String? newValue) {
                  setState(() => _workerType = newValue!);
                },
              ),
              const SizedBox(height: 20),

              // ✅ Submit Button
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

  // ✅ Reusable TextField Widget
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
      validator: (value) {
        if (value == null || value.isEmpty) return "Please enter $label";
        if (label == "Email" &&
            !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
          return "Enter a valid email";
        }
        if (label == "Phone Number" &&
            !RegExp(r"^[0-9]{10,15}$").hasMatch(value)) {
          return "Enter a valid phone number";
        }
        return null;
      },
    );
  }

  // ✅ Worker Type Dropdown
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
