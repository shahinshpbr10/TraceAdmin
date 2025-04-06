import 'dart:io';

import 'package:admin/Common/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String gender = 'Male';
  String profilePicUrl = '';
  File? _imageFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('busOwners').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        gender = data['gender'] ?? 'Male';
        profilePicUrl = data['profilePic'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String> uploadProfileImage(String uid) async {
    final ref = _storage.ref().child('profile_pics/$uid.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> saveChanges() async {
    final uid = _auth.currentUser!.uid;
    String? newImageUrl = profilePicUrl;

    if (_imageFile != null) {
      newImageUrl = await uploadProfileImage(uid);
    }

    await _firestore.collection('busOwners').doc(uid).update({
      'name': nameController.text,
      'address': addressController.text,
      'gender': gender,
      'profilePic': newImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: Text("My Profile", style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Profile picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (profilePicUrl.isNotEmpty
                      ? NetworkImage(profilePicUrl)
                      : const AssetImage("assets/images/profile.jpg")) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => pickImage(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3D5AFE),
                      ),
                      child: const Icon(Iconsax.edit, color: Colors.white, size: 16),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField("Full Name", Iconsax.user, nameController),
            const SizedBox(height: 16),
            _buildTextField("Email", Iconsax.direct, emailController, readOnly: true),
            const SizedBox(height: 16),
            _buildTextField("Phone", Iconsax.call, phoneController, readOnly: true),
            const SizedBox(height: 16),
            _buildTextField("Address", Iconsax.location, addressController),
            const SizedBox(height: 16),

            // Gender Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: gender,
                icon: const Icon(Iconsax.arrow_down),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Gender",
                ),
                items: ['Male', 'Female', 'Others']
                    .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (val) => setState(() => gender = val!),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2, color: Colors.white),
                label: Text(
                  "Save Changes",
                  style: AppTextStyles.smallBodyText.copyWith(color: Colors.white),
                ),
                onPressed: saveChanges,
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      style: AppTextStyles.smallBodyText,
      controller: controller,
      readOnly: readOnly,
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
