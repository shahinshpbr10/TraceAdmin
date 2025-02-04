import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  File? _profilePic;
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _nameController = TextEditingController();
  final _busAssignedController = TextEditingController();
  String _workerType = 'Driver'; // Default worker type

  // Method to pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profilePic = File(pickedFile.path);
      }
    });
  }

  // Method to submit the form
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Process the data (save to database, etc.)
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Success'),
          content: Text('Worker added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can clear the form or navigate somewhere else here
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Worker'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Picture Section
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    backgroundImage: _profilePic != null
                        ? FileImage(_profilePic!)
                        : null,
                    child: _profilePic == null
                        ? Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.black.withOpacity(0.5),
                    )
                        : null,
                  ),
                ),
                SizedBox(height: 16),

                // Name TextField
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Email TextField
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Worker Type Dropdown
                DropdownButtonFormField<String>(
                  value: _workerType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _workerType = newValue!;
                    });
                  },
                  items: ['Driver', 'Conductor', 'Helper']
                      .map((String type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Worker Type',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Bus Assigned TextField
                TextFormField(
                  controller: _busAssignedController,
                  decoration: InputDecoration(
                    labelText: 'Bus Assigned',
                    prefixIcon: Icon(Icons.directions_bus),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the bus assigned';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // License TextField for Driver
                if (_workerType == 'Driver')
                  TextFormField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: 'License Number',
                      prefixIcon: Icon(Icons.card_travel),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a license number';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.purple),
                  ),
                  child: Text(
                    'Submit',
                  
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
