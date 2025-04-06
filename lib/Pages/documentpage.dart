import 'dart:io';

import 'package:admin/Common/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> allDocuments = [];
  List<Map<String, dynamic>> filteredDocuments = [];
  String? selectedType;

  final List<String> docTypes = [
    'Bus Insurance',
    'Bus License',
    'Driver License',
    'Pollution Test',
    'Fitness Certificate',
    'Permit',
    'RC Book',
    'Road Tax',
    'Service Record',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    List<Map<String, dynamic>> docs = [];

    final buses = await _firestore.collection('busOwners').doc(uid).collection('buses').get();
    for (var bus in buses.docs) {
      final docsSnap = await bus.reference.collection('documents').get();
      for (var doc in docsSnap.docs) {
        docs.add({...doc.data(), 'ownerType': 'Bus', 'ownerName': bus.data()['name']});
      }
    }

    final workers = await _firestore.collection('busOwners').doc(uid).collection('workers').get();
    for (var worker in workers.docs) {
      final docsSnap = await worker.reference.collection('documents').get();
      for (var doc in docsSnap.docs) {
        docs.add({...doc.data(), 'ownerType': 'Worker', 'ownerName': worker.data()['name']});
      }
    }

    final expenses = await _firestore.collection('busOwners').doc(uid).collection('expenses').get();
    for (var expense in expenses.docs) {
      final docsSnap = await expense.reference.collection('documents').get();
      for (var doc in docsSnap.docs) {
        docs.add({...doc.data(), 'ownerType': 'Expense', 'ownerName': expense.data()['type']});
      }
    }

    final manualDocs = await _firestore.collection('busOwners').doc(uid).collection('manualDocuments').get();
    for (var doc in manualDocs.docs) {
      docs.add({...doc.data(), 'ownerType': 'Manual Upload', 'ownerName': 'General'});
    }

    setState(() {
      allDocuments = docs;
      filteredDocuments = docs;
    });
  }

  void _uploadDocument() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || selectedType == null) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final ref = _storage.ref().child('manualDocuments/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);
    final fileUrl = await ref.getDownloadURL();

    await _firestore.collection('busOwners').doc(uid).collection('manualDocuments').add({
      'title': selectedType,
      'fileUrl': fileUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
      'ownerType': 'Manual Upload',
      'ownerName': 'General'
    });

    _fetchDocuments();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Text("Filter Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...docTypes.map((type) => ListTile(
                title: Text(type),
                onTap: () {
                  setState(() {
                    selectedType = type;
                    filteredDocuments = allDocuments.where((doc) => doc['title'] == type).toList();
                  });
                  Navigator.pop(context);
                },
              )),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedType = null;
                    filteredDocuments = allDocuments;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Clear Filter"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Column(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Documents",
                    style: AppTextStyles.smallBodyText.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Iconsax.folder_open, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search documents...",
                      prefixIcon: const Icon(Iconsax.search_normal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        filteredDocuments = allDocuments.where((doc) {
                          return doc['title'].toString().toLowerCase().contains(query.toLowerCase());
                        }).toList();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Iconsax.setting_4),
                ),
                IconButton(
                  onPressed: _uploadDocument,
                  icon: const Icon(Iconsax.document_download),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDocuments.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final doc = filteredDocuments[index];
                return GestureDetector(
                  onTap: () => launchUrl(Uri.parse(doc['fileUrl'])),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.document, color: Color(0xFF3D5AFE), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          doc['title'] ?? 'No Title',
                          style: AppTextStyles.smallBodyText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "From: ${doc['ownerType']} - ${doc['ownerName'] ?? ''}",
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
