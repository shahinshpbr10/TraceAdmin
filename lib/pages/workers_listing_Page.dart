import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Worker {
  final String id;
  String name;
  String email;
  String workerType;
  String busAssigned;
  String profilePic;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.workerType,
    required this.busAssigned,
    required this.profilePic,
  });

  // Factory method to create Worker from Firestore document
  factory Worker.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Worker(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No Email',
      workerType: data['workerType'] ?? 'Unknown',
      busAssigned: data['busAssigned'] ?? 'Not Assigned',
      profilePic: data['profilePicUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

class WorkerListingPage extends StatefulWidget {
  const WorkerListingPage({super.key});

  @override
  State<WorkerListingPage> createState() => _WorkerListingPageState();
}

class _WorkerListingPageState extends State<WorkerListingPage> {
  String? _adminId;
  List<Worker> workers = [];
  List<Worker> filteredWorkers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch logged-in Admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid;
      });
    }
  }

  // ✅ Search Filter Method
  void _filterWorkers(String query) {
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker.name.toLowerCase().contains(query.toLowerCase()) ||
            worker.workerType.toLowerCase().contains(query.toLowerCase()) ||
            worker.busAssigned.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Workers'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _adminId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("admins")
            .doc(_adminId)
            .collection("workers")
            .snapshots(), // ✅ Real-time updates from sub-collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workers available."));
          }

          workers = snapshot.data!.docs.map((doc) => Worker.fromFirestore(doc)).toList();
          filteredWorkers = workers;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      return _buildWorkerCard(filteredWorkers[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Search Bar
  Widget _buildSearchBar() {
    return Container(
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
          hintText: "Search workers...",
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        onChanged: (query) => _filterWorkers(query),
      ),
    );
  }

  // ✅ Worker Card UI
  Widget _buildWorkerCard(Worker worker) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(worker.profilePic),
          radius: 30,
        ),
        title: Text(worker.name),
        subtitle: Text('Bus Assigned: ${worker.busAssigned}'),
        trailing: Chip(
          label: Text(worker.workerType),
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
        ),
        onTap: () => _showEditDialog(worker),
      ),
    );
  }

  // ✅ Show Edit Worker Dialog
  void _showEditDialog(Worker worker) {
    TextEditingController nameController = TextEditingController(text: worker.name);
    TextEditingController busAssignedController = TextEditingController(text: worker.busAssigned);
    File? newProfileImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Worker Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      newProfileImage = File(pickedFile.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: newProfileImage != null
                      ? FileImage(newProfileImage!)
                      : NetworkImage(worker.profilePic) as ImageProvider,
                  child: newProfileImage == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: busAssignedController, decoration: const InputDecoration(labelText: "Bus Assigned")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () {
                _updateWorker(worker, nameController.text, busAssignedController.text, newProfileImage);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Update Worker Details in Firestore
  Future<void> _updateWorker(Worker worker, String newName, String newBusAssigned, File? newImage) async {
    if (_adminId == null) return;

    try {
      String imageUrl = worker.profilePic;

      if (newImage != null) {
        String fileName = '${worker.id}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('workers/$fileName');
        UploadTask uploadTask = ref.putFile(newImage);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection("admins").doc(_adminId).collection("workers").doc(worker.id).update({
        "name": newName,
        "busAssigned": newBusAssigned,
        "profilePicUrl": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Worker updated successfully!"), backgroundColor: Colors.green));
    } catch (e) {
      print("❌ Error updating worker: $e");
    }
  }
}
