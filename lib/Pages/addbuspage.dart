import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? busImageFile;
  List<Map<String, dynamic>> allWorkers = [];
  List<String> drivers = [];
  List<String> helpers = [];
  List<String> cleaners = [];
  List<String> others = [];


  String? selectedDriver;
  String? selectedHelper;

  List<Map<String, dynamic>> routes = [];

  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController routePriceController = TextEditingController();

  Future<void> _pickBusImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        busImageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveBusToFirebase() async {
    final uid = _auth.currentUser?.uid;
    final name = busNameController.text.trim();
    final numberPlate = numberPlateController.text.trim();

    if (name.isEmpty ||
        numberPlate.isEmpty ||
        selectedDriver == null ||
        selectedHelper == null ||
        busImageFile == null ||
        routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields, upload image & add at least one route.")),
      );
      return;
    }

    try {
      final busId = _firestore.collection('buses').doc().id;

      // Upload bus image
      final imageRef = _storage.ref().child('buses/$uid/$busId/bus.jpg');
      await imageRef.putFile(busImageFile!);
      final imageUrl = await imageRef.getDownloadURL();

      // Convert routes to Map<String, dynamic>
      final Map<String, dynamic> routeMap = {
        for (var route in routes)
          route['name']: double.tryParse(route['price']) ?? 0,
      };

      // Build today's date key
      final now = DateTime.now();
      final dateKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Build multi-day supported report structure
      final Map<String, dynamic> dailyPassengerReport = {
        dateKey: {
          'passengerCountTotal': 0,
          'entryCount': 0,
          'exitCount': 0,
          'revenueOfTheDay': 0,
        }
      };

      // Save to Firestore
      await _firestore
          .collection('busOwners')
          .doc(uid)
          .collection('buses')
          .doc(busId)
          .set({
        'busId': busId,
        'name': name,
        'numberPlate': numberPlate,
        'driver': selectedDriver,
        'helper': selectedHelper,
        'routes': routeMap,
        'image': imageUrl,
        'dailyPassengerReport': dailyPassengerReport,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('busOwners')
        .doc(uid)
        .collection('workers')
        .get();

    final List<Map<String, dynamic>> fetched = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      allWorkers = fetched;

      drivers = fetched
          .where((w) => w['role'] == 'Driver')
          .map((w) => w['name'] as String)
          .toList();

      helpers = fetched
          .where((w) => w['role'] == 'Helper')
          .map((w) => w['name'] as String)
          .toList();

      cleaners = fetched
          .where((w) => w['role'] == 'Cleaner')
          .map((w) => w['name'] as String)
          .toList();

      others = fetched
          .where((w) => w['role'] == 'Other')
          .map((w) => w['name'] as String)
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("Add Bus"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Bus image
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: busImageFile != null
                      ? FileImage(busImageFile!)
                      : const AssetImage("assets/bus.png",  ) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickBusImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3D5AFE),
                      ),
                      child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            _buildTextField("Bus Name", Iconsax.bus, busNameController),
            const SizedBox(height: 16),
            _buildTextField("Number Plate", Iconsax.car, numberPlateController),
            const SizedBox(height: 16),

            _buildDropdown("Assign Driver", drivers, selectedDriver, (val) {
              setState(() => selectedDriver = val);
            }),
            const SizedBox(height: 24),
            _buildDropdown("Assign Helper", helpers, selectedHelper, (val) {
              setState(() => selectedHelper = val);
            }),
            const SizedBox(height: 24),

            // Routes Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Routes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField("Route Name", Iconsax.map, routeNameController),
            const SizedBox(height: 12),
            _buildTextField("Price", Iconsax.money, routePriceController,
                inputType: TextInputType.number),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  if (routeNameController.text.isNotEmpty &&
                      routePriceController.text.isNotEmpty) {
                    setState(() {
                      routes.add({
                        'name': routeNameController.text,
                        'price': routePriceController.text
                      });
                      routeNameController.clear();
                      routePriceController.clear();
                    });
                  }
                },
                icon: const Icon(Iconsax.add_circle),
                label: const Text("Add Route"),
              ),
            ),

            // Show Added Routes
            if (routes.isNotEmpty)
              Column(
                children: routes.map((route) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${route['name']} - ₹${route['price']}"),
                        IconButton(
                          icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                          onPressed: () {
                            setState(() => routes.remove(route));
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2),
                label: const Text("Save Bus"),
                onPressed: _saveBusToFirebase,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF3D5AFE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        icon: const Icon(Iconsax.arrow_down),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
