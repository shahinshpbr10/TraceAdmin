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
    // Open the file picker to select any type of file (image, PDF, etc.)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;
      String fileType = result.files.single.extension ?? 'Unknown';

      if (filePath != null) {
        // Show the modal to enter document name and description
        _showDocumentDetailsModal(filePath, fileName, fileType);
      }
    }
  }

  // Method to show the modal bottom sheet for entering document details
  void _showDocumentDetailsModal(
      String filePath, String fileName, String fileType) {
    TextEditingController nameController =
        TextEditingController(text: fileName);
    TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Document Details',
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Document Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Document Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    documents.add(Document(
                      name: nameController.text,
                      type: fileType,
                      path: filePath,
                      description: descriptionController.text,
                    ));
                    filteredDocuments = documents; // Update filtered list
                  });
                  Navigator.pop(context); // Close the modal
                },
                child: Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to filter documents based on the search query
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
      appBar: AppBar(
        title: Text('Add & View Documents'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Documents',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) => _filterDocuments(query),
            ),
            SizedBox(height: 16),

            // Button to upload a document
            ElevatedButton(
              onPressed: _uploadDocument,
              child: Text('Add Document'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),

            // Display the list of documents
            Expanded(
              child: ListView.builder(
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(doc.name),
                      subtitle: Text(
                          'Type: ${doc.type} | Description: ${doc.description}'),
                      trailing: Icon(Icons.remove_red_eye),
                      onTap: () {
                        // Handle document tap (e.g., show the document or open it)
                        print('Tapped on: ${doc.name}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
