import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Document {
  final String name;
  final String type;
  final String path;
  final String description;

  Document({
    required this.name,
    required this.type,
    required this.path,
    required this.description,
  });
}

class AddViewDocumentsPage extends StatefulWidget {
  const AddViewDocumentsPage({super.key});

  @override
  State<AddViewDocumentsPage> createState() => _AddViewDocumentsPageState();
}

class _AddViewDocumentsPageState extends State<AddViewDocumentsPage> {
  List<Document> documents = [];
  List<Document> filteredDocuments = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDocuments = documents;
  }

  // Method to open file picker and upload a document
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

  // Modal bottom sheet for entering document details
  void _showDocumentDetailsModal(String filePath, String fileName, String fileType) {
    TextEditingController nameController = TextEditingController(text: fileName);
    TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Document Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Document Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Document Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    documents.add(Document(
                      name: nameController.text,
                      type: fileType,
                      path: filePath,
                      description: descriptionController.text,
                    ));
                    filteredDocuments = documents;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add Document', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Search filtering function
  void _filterDocuments(String query) {
    setState(() {
      filteredDocuments = documents.where((doc) {
        return doc.name.toLowerCase().contains(query.toLowerCase()) ||
            doc.type.toLowerCase().contains(query.toLowerCase()) ||
            doc.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add & View Documents'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  hintText: "Search documents...",
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onChanged: (query) => _filterDocuments(query),
              ),
            ),
            const SizedBox(height: 16),

            // Document List
            Expanded(
              child: filteredDocuments.isEmpty
                  ? const Center(
                child: Text(
                  "No documents available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];
                  return _buildDocumentCard(doc);
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for adding documents
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          "Add Document",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Document Card UI
  Widget _buildDocumentCard(Document doc) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple, size: 36),
        title: Text(
          doc.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Type: ${doc.type} | ${doc.description}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.remove_red_eye, color: Colors.deepPurple),
        onTap: () {
          // Handle document tap (e.g., open document)
          print('Tapped on: ${doc.name}');
        },
      ),
    );
  }
}
