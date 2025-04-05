import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  final TextEditingController licenseController = TextEditingController();
  String selectedRole = "Helper";
  File? licenseFile;


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
            // Profile pic upload
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/images/worker.png"), // Replace or upload
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3D5AFE),
                    ),
                    child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Name
            _buildTextField("Full Name", Iconsax.user, nameController),
            const SizedBox(height: 24),
            _buildTextField("Phone number", Iconsax.call, nameController),

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
                  // Save logic here
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
