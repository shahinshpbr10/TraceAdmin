import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Bus {
  final String id;
  String name;
  String route;
  String numberPlate;
  String imageUrl;

  Bus({
    required this.id,
    required this.name,
    required this.route,
    required this.numberPlate,
    required this.imageUrl,
  });

  // Factory method to create Bus from Firestore document
  factory Bus.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bus(
      id: doc.id,
      name: data['name'] ?? '',
      route: data['route'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

class BusListingPage extends StatefulWidget {
  const BusListingPage({super.key});

  @override
  State<BusListingPage> createState() => _BusListingPageState();
}

class _BusListingPageState extends State<BusListingPage> {
  List<Bus> buses = [];
  List<Bus> filteredBuses = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  // Fetch Buses from Firestore
  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("buses").get();

      List<Bus> busList =
      querySnapshot.docs.map((doc) => Bus.fromFirestore(doc)).toList();

      setState(() {
        buses = busList;
        filteredBuses = busList;
        _isLoading = false;
      });
    } catch (e) {
      print("🔥 Error fetching buses: $e");
      setState(() => _isLoading = false);
    }
  }

  // Search Filter Method
  void _filterBuses(String query) {
    setState(() {
      filteredBuses = buses.where((bus) {
        return bus.name.toLowerCase().contains(query.toLowerCase()) ||
            bus.route.toLowerCase().contains(query.toLowerCase()) ||
            bus.numberPlate.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Update Bus Details in Firestore
  Future<void> _updateBus(Bus bus, String newName, String newRoute, String newNumberPlate, File? newImage) async {
    try {
      String imageUrl = bus.imageUrl;

      // If new image is picked, upload it to Firebase Storage
      if (newImage != null) {
        String fileName = '${bus.id}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('buses/$fileName');
        UploadTask uploadTask = ref.putFile(newImage);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update Firestore record
      await FirebaseFirestore.instance.collection("buses").doc(bus.id).update({
        "name": newName,
        "route": newRoute,
        "numberPlate": newNumberPlate,
        "imageUrl": imageUrl,
      });

      // Update UI
      setState(() {
        bus.name = newName;
        bus.route = newRoute;
        bus.numberPlate = newNumberPlate;
        bus.imageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bus updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("❌ Error updating bus: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update bus!"), backgroundColor: Colors.red),
      );
    }
  }

  // Show Alert Dialog for Editing Bus Details
  void _showEditDialog(Bus bus) {
    TextEditingController nameController = TextEditingController(text: bus.name);
    TextEditingController routeController = TextEditingController(text: bus.route);
    TextEditingController numberPlateController = TextEditingController(text: bus.numberPlate);
    File? newBusImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Bus Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      newBusImage = File(pickedFile.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: newBusImage != null
                      ? FileImage(newBusImage!)
                      : NetworkImage(bus.imageUrl) as ImageProvider,
                  child: newBusImage == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Bus Name"),
              ),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(labelText: "Route Number"),
              ),
              TextField(
                controller: numberPlateController,
                decoration: const InputDecoration(labelText: "Number Plate"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                _updateBus(bus, nameController.text, routeController.text, numberPlateController.text, newBusImage);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Buses'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search buses...",
                  border: InputBorder.none,
                  prefixIcon:
                  const Icon(Icons.search, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                ),
                onChanged: (query) => _filterBuses(query),
              ),
            ),
            const SizedBox(height: 16),

            // Bus List
            Expanded(
              child: filteredBuses.isEmpty
                  ? const Center(
                child: Text(
                  "No buses found",
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredBuses.length,
                itemBuilder: (context, index) {
                  final bus = filteredBuses[index];
                  return _buildBusCard(bus);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bus Card UI
  Widget _buildBusCard(Bus bus) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(bus.imageUrl),
          radius: 30,
        ),
        title: Text(bus.name),
        subtitle: Text('Route: ${bus.route} | Plate: ${bus.numberPlate}'),
        trailing: const Icon(Icons.edit, color: Colors.deepPurple),
        onTap: () => _showEditDialog(bus),
      ),
    );
  }
}
