import 'package:admin/Common/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordPage extends StatelessWidget {
   ForgotPasswordPage({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
                // Optional SVG at top
                SizedBox(
                  height: size.height * 0.15,
                  child: SvgPicture.asset(
                    'assets/Images/forgot.svg', // Add your SVG file
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Forgot Password?",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  "Enter your email and we'll send you a reset link.",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF6C7A96),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email field
                TextFormField(controller: emailController,
                  style: AppTextStyles.smallBodyText,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Iconsax.direct),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),

                // Send Reset Link Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter your email")),
                        );
                        return;
                      }

                      try {
                        await _auth.sendPasswordResetEmail(email: email);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password reset link sent! Check your email."),
                            backgroundColor: Color(0xFF3D5AFE),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        String message = "Something went wrong";
                        if (e.code == 'user-not-found') {
                          message = "No user found with this email";
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF3D5AFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Send Reset Link",
                      style: AppTextStyles.smallBodyText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(color: Color(0xFF3D5AFE)),
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
