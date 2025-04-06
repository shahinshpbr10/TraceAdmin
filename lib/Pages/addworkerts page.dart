import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../Common/text_styles.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  String selectedRole = "Helper"; // 🔄 Keep it here (class level)
  File? licenseFile;
  File? profileImageFile;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        profileImageFile = File(result.files.single.path!);
      });
    }
  }
  Future<void> _saveWorker() async {
    final uid = _auth.currentUser!.uid;
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final license = licenseController.text.trim();

    // === Validate Required Fields ===
    if (name.isEmpty || phone.isEmpty) {
      _showError("Please enter both name and phone number");
      return;
    }

    if (profileImageFile == null) {
      _showError("Please upload a profile picture");
      return;
    }

    if (selectedRole == "Driver") {
      if (license.isEmpty) {
        _showError("Please enter the license number");
        return;
      }

      if (licenseFile == null) {
        _showError("Please upload the license file (PDF or image)");
        return;
      }
    }

    try {
      final workerId = _firestore.collection('workers').doc().id;

      // Upload profile image
      String? profileUrl;
      final profileRef = _storage.ref().child('workers/$uid/$workerId/profile.jpg');
      await profileRef.putFile(profileImageFile!);
      profileUrl = await profileRef.getDownloadURL();

      // Upload license file if driver
      String? licenseFileUrl;
      if (selectedRole == "Driver" && licenseFile != null) {
        final fileExt = licenseFile!.path.split('.').last;
        final licenseRef = _storage.ref().child('workers/$uid/$workerId/license.$fileExt');
        await licenseRef.putFile(licenseFile!);
        licenseFileUrl = await licenseRef.getDownloadURL();
      }

      // Save to Firestore
      await _firestore
          .collection('busOwners')
          .doc(uid)
          .collection('workers')
          .doc(workerId)
          .set({
        'name': name,
        'phone': phone,
        'role': selectedRole,
        'profileImage': profileUrl,
        'licenseNumber': selectedRole == 'Driver' ? license : null,
        'licenseFile': licenseFileUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title:  Text("Add Worker",style: AppTextStyles.heading2.copyWith(color: Colors.white),),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageFile != null
                      ? FileImage(profileImageFile!)
                      : const AssetImage("assets/b1.png") as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
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

            // Name
            _buildTextField("Full Name", Iconsax.user, nameController),
            const SizedBox(height: 24),
            _buildTextField("Phone number", Iconsax.call, phoneController),

            const SizedBox(height: 16),

            // Role dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedRole,
                icon: const Icon(Iconsax.arrow_down),
                decoration: const InputDecoration(
                  labelText: "Select Role",
                  border: InputBorder.none,
                ),
                items: ["Driver", "Helper", "Cleaner", "Other"]
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
            ),

            const SizedBox(height: 16),

            if (selectedRole == "Driver") ...[
              _buildTextField("License Number", Iconsax.document, licenseController),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickLicenseFile,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.document_upload, color: Color(0xFF3D5AFE)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          licenseFile != null
                              ? "Selected: ${licenseFile!.path.split('/').last}"
                              : "Upload License File (PDF or Image)",
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],


            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:  Icon(Iconsax.save_2,color: Colors.white,),
                label:  Text("Save Worker",style: AppTextStyles.smallBodyText.copyWith(color: Colors.white),),
                onPressed: () {
                  _saveWorker();
                },
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
  Future<void> _pickLicenseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        licenseFile = File(result.files.single.path!);
      });
    }
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(style: AppTextStyles.smallBodyText,
      controller: controller,
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
}
