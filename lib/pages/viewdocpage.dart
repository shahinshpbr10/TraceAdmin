import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BusDocumentsPage extends StatefulWidget {
  const BusDocumentsPage({super.key});

  @override
  State<BusDocumentsPage> createState() => _BusDocumentsPageState();
}

class _BusDocumentsPageState extends State<BusDocumentsPage> {
  String? _adminId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch the logged-in Admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid;
      });
      _fetchDocuments();
    }
  }

  // ✅ Fetch Bus Documents from Firestore
  Future<void> _fetchDocuments() async {
    if (_adminId == null) return;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("admins")
          .doc(_adminId)
          .collection("busDocuments")
          .orderBy("expiryDate", descending: false)
          .get();

      setState(() {
        _documents = snapshot.docs
            .map((doc) => {"docId": doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });

      _checkForExpiringDocuments();
    } catch (e) {
      print("🔥 Error fetching documents: $e");
      setState(() => _isLoading = false);
    }
  }

  // ✅ Check if any documents are about to expire
  void _checkForExpiringDocuments() {
    DateTime today = DateTime.now();
    DateTime warningDate = today.add(const Duration(days: 7)); // 7 days before expiry

    for (var doc in _documents) {
      Timestamp expiryTimestamp = doc["expiryDate"];
      DateTime expiryDate = expiryTimestamp.toDate();

      if (expiryDate.isBefore(warningDate) && expiryDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ ${doc['name']} is expiring soon on ${DateFormat.yMMMd().format(expiryDate)}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // ✅ File Picker and Upload
  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;
      String fileType = result.files.single.extension ?? 'Unknown';

      if (filePath != null) {
        _showDocumentDetailsModal(filePath, fileName, fileType);
      }
    }
  }

  // ✅ Show Modal for Document Details Input
  void _showDocumentDetailsModal(String filePath, String fileName, String fileType) {
    TextEditingController nameController = TextEditingController(text: fileName);
    TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30)); // Default: 30 days from today

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter Document Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Document Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Document Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text("Expiry Date: ${DateFormat.yMMMd().format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveDocument(nameController.text, descriptionController.text, fileType, filePath, selectedDate),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 50)),
                child: const Text('Upload Document', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Save Document to Firestore & Upload to Firebase Storage
  Future<void> _saveDocument(String name, String description, String type, String filePath, DateTime expiryDate) async {
    if (_adminId == null) return;

    setState(() => _isLoading = true);
    String fileUrl = "";

    try {
      File file = File(filePath);
      String fileName = "${DateTime.now().millisecondsSinceEpoch}-$name";
      Reference ref = FirebaseStorage.instance.ref().child('busDocuments/$_adminId/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      fileUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("🔥 Error uploading document: $e");
    }

    try {
      await _firestore.collection("admins").doc(_adminId).collection("busDocuments").add({
        "name": name,
        "description": description,
        "type": type,
        "fileUrl": fileUrl,
        "expiryDate": Timestamp.fromDate(expiryDate),
        "createdAt": FieldValue.serverTimestamp(),
      });

      _fetchDocuments();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("🔥 Firestore error: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Documents"), backgroundColor: Colors.deepPurple),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          var doc = _documents[index];
          return ListTile(
            title: Text(doc["name"]),
            subtitle: Text("Expires on: ${DateFormat.yMMMd().format(doc["expiryDate"].toDate())}"),
            trailing: const Icon(Icons.visibility, color: Colors.deepPurple),
            onTap: () {
              // Open document URL
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text("Add Document"),
      ),
    );
  }
}
