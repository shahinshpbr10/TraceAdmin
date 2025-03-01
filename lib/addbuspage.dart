import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _numberPlateController = TextEditingController();
  final _stopController = TextEditingController();
  final _fareController = TextEditingController();
  bool _isLoading = false;

  String? _selectedDriver;
  String? _selectedConductor;
  String? _adminId;

  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _conductors = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
    _fetchWorkers();
  }

  // ✅ Fetch logged-in admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid; // Admin ID = Current User ID
      });
    }
  }

// ✅ Fetch Drivers and Conductors from Firestore (admins/{adminId}/workers)
  Future<void> _fetchWorkers() async {
    if (_adminId == null) return;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection("admins")
          .doc(_adminId) // ✅ Fetch workers under the current admin
          .collection("workers")
          .get();

      setState(() {
        _drivers = snapshot.docs
            .where((doc) => doc["workerType"] == "Driver")
            .map((doc) => {
          "id": doc.id, // Worker Document ID
          "name": doc["name"] ?? "Unknown",
          "email": doc["email"] ?? "",
          "phone": doc["phone"] ?? "",
          "profilePicUrl": doc["profilePicUrl"] ?? "",
        })
            .toList();

        _conductors = snapshot.docs
            .where((doc) => doc["workerType"] == "Conductor")
            .map((doc) => {
          "id": doc.id, // Worker Document ID
          "name": doc["name"] ?? "Unknown",
          "email": doc["email"] ?? "",
          "phone": doc["phone"] ?? "",
          "profilePicUrl": doc["profilePicUrl"] ?? "",
        })
            .toList();
      });

    } catch (e) {
      print("🔥 Error fetching workers: $e");
    }
  }


  // ✅ Select image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _busImage = File(pickedFile.path);
      });
    }
  }

  // ✅ Upload image to Firebase Storage
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

  // ✅ Add stop with fare
  void _addRoute() {
    if (_stopController.text.trim().isNotEmpty && _fareController.text.trim().isNotEmpty) {
      setState(() {
        _routes.add({
          "stop": _stopController.text.trim(),
          "fare": int.parse(_fareController.text.trim())
        });
        _stopController.clear();
        _fareController.clear();
      });
    }
  }

  // ✅ Remove stop
  void _removeRoute(Map<String, dynamic> route) {
    setState(() {
      _routes.remove(route);
    });
  }

  // ✅ Submit form and save bus data
  Future<void> _submitForm() async {
    if (_adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin ID not found!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate() ||
        _selectedDriver == null ||
        _selectedConductor == null ||
        _routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add at least one route!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? busImageUrl = await _uploadBusImage();
    String busId = const Uuid().v4();

    Map<String, dynamic> busData = {
      "busId": busId,
      "name": _nameController.text.trim(),
      "numberPlate": _numberPlateController.text.trim(),
      "ownerId": _adminId,
      "driverId": _selectedDriver,
      "conductorId": _selectedConductor,
      "routes": _routes,
      "passengerCount": 0,
      "revenue": 0,
      "imageUrl": busImageUrl ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection("admins").doc(_adminId).collection("buses").doc(busId).set(busData);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus added successfully!"), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text("Add Bus")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _busImage != null ? FileImage(_busImage!) : null,
                  child: _busImage == null ? const Icon(Icons.camera_alt, size: 35, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Bus Name", Icons.directions_bus),
              const SizedBox(height: 15),

              _buildTextField(_numberPlateController, "Number Plate", Icons.confirmation_number),
              const SizedBox(height: 15),
              _buildDropdown("Select Driver", _selectedDriver, _drivers, (val) {
                setState(() => _selectedDriver = val);
              }),
              const SizedBox(height: 15),
              _buildDropdown("Select Conductor", _selectedConductor, _conductors, (val) {
                setState(() => _selectedConductor = val);
              }),

              const SizedBox(height: 15),

              _buildRouteSection(),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }

  Widget _buildRouteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bus Route Stops",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Input fields for stop name and fare
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _stopController,
                decoration: InputDecoration(
                  hintText: "Enter stop name",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _fareController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter fare (₹)",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Display added stops with fares
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _routes
              .map((route) => Chip(
            label: Text("${route['stop']} - ₹${route['fare']}"),
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => _removeRoute(route),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label,
      String? selectedValue,
      List<Map<String, dynamic>> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      onChanged: onChanged,
      items: items.map((worker) {
        return DropdownMenuItem<String>(
          value: worker["id"], // Unique worker ID
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                backgroundImage: worker["profilePicUrl"].isNotEmpty
                    ? NetworkImage(worker["profilePicUrl"])
                    : null,
                child: worker["profilePicUrl"].isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(worker["name"] ?? "Unknown"),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select $label";
        }
        return null;
      },
    );
  }


}
