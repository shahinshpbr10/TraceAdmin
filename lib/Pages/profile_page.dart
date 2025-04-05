import 'package:admin/Common/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController =
  TextEditingController(text: "Shamil");
  final TextEditingController emailController =
  TextEditingController(text: "shamil@example.com");
  final TextEditingController phoneController =
  TextEditingController(text: "+91 9876543210");
  final TextEditingController addressController = TextEditingController();

  String gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title:  Text("My Profile",style:AppTextStyles.heading2.copyWith(color: Colors.white) ,),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Profile picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: const AssetImage("assets/images/profile.jpg"), // Replace or allow upload
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3D5AFE),
                    ),
                    child: const Icon(Iconsax.edit, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Form fields
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
                icon: const Icon(Iconsax.save_2,color: Colors.white,),
                label:  Text("Save Changes",style: AppTextStyles.smallBodyText.copyWith(color: Colors.white),),
                onPressed: () {
                  // Handle saving logic
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

  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller,
      {bool readOnly = false}) {
    return TextField(style: AppTextStyles.smallBodyText,
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
