import 'package:admin/Common/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // App Name
                Text(
                  "Trace Admin",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF6C7A96),
                  ),
                ),
                const SizedBox(height: 40),

                // Full Name
                TextFormField(
                  style: AppTextStyles.smallBodyText,
                  decoration: _inputDecoration("Full Name", Iconsax.personalcard),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  style: AppTextStyles.smallBodyText,
                  decoration: _inputDecoration("Email", Iconsax.direct_inbox),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  style: AppTextStyles.smallBodyText,
                  decoration: _inputDecoration("Phone Number", Iconsax.call),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  style: AppTextStyles.smallBodyText,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Iconsax.lock),
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF3D5AFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: AppTextStyles.smallBodyText.copyWith(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: AppTextStyles.smallBodyText),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Color(0xFF3D5AFE)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
