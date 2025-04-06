import 'package:admin/Common/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool oldPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;

  void _handleChangePassword() async {
    final oldPass = oldPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password and confirmation do not match")),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password must be at least 6 characters")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(cred);

      // Update the password
      await user.updatePassword(newPass);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );

      // Clear the fields
      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
    } on FirebaseAuthException catch (e) {
      String error = "Something went wrong";
      if (e.code == 'wrong-password') {
        error = "Old password is incorrect";
      } else if (e.code == 'requires-recent-login') {
        error = "Please log in again to change your password";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: Text("Change Password",style: AppTextStyles.heading2.copyWith(color: Colors.white
        ),),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildPasswordField(
              label: "Old Password",
              controller: oldPassController,
              visible: oldPassVisible,
              toggleVisibility: () =>
                  setState(() => oldPassVisible = !oldPassVisible),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: "New Password",
              controller: newPassController,
              visible: newPassVisible,
              toggleVisibility: () =>
                  setState(() => newPassVisible = !newPassVisible),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: "Confirm New Password",
              controller: confirmPassController,
              visible: confirmPassVisible,
              toggleVisibility: () =>
                  setState(() => confirmPassVisible = !confirmPassVisible),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleChangePassword,
                icon: const Icon(Iconsax.password_check,color: Colors.white,),
                label:  Text("Save Password",style: AppTextStyles.smallBodyText.copyWith(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(style: AppTextStyles.smallBodyText,
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Iconsax.lock),
        suffixIcon: IconButton(
          icon: Icon(visible ? Iconsax.eye : Iconsax.eye_slash),
          onPressed: toggleVisibility,
        ),
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
