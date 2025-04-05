import 'package:admin/Common/text_styles.dart';
import 'package:admin/Pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

class SignupPage extends StatelessWidget {
  SignupPage({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                  controller: nameController,
                  style: AppTextStyles.smallBodyText,
                  decoration:
                      _inputDecoration("Full Name", Iconsax.personalcard),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  style: AppTextStyles.smallBodyText,
                  decoration: _inputDecoration("Email", Iconsax.direct_inbox),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: phoneController,
                  style: AppTextStyles.smallBodyText,
                  decoration: _inputDecoration("Phone Number", Iconsax.call),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  style: AppTextStyles.smallBodyText,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Iconsax.lock),
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();

                        if (email.isEmpty ||
                            password.isEmpty ||
                            name.isEmpty ||
                            phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")),
                          );
                          return;
                        }

                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Password must be at least 6 characters")),
                          );
                          return;
                        }

                        // Create user
                        final userCredential =
                            await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // Optionally: update display name
                        await _auth.currentUser?.updateDisplayName(name);

                        // Save to Firestore
                        await FirebaseFirestore.instance
                            .collection('busOwners')
                            .doc(userCredential.user!.uid)
                            .set({
                          'name': name,
                          'email': email,
                          'phone': phone,
                          'uid': userCredential.user!.uid,
                          'profilePic':"null",
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Navigate to home
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) {
                              return LoginPage();
                            },
                          ),
                              (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account Creation Success')),
                        );
                      } on FirebaseAuthException catch (e) {
                        String message = "Signup failed";
                        if (e.code == 'email-already-in-use') {
                          message = "Email already in use";
                        } else if (e.code == 'weak-password') {
                          message = "Password should be at least 6 characters";
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) {
                              return LoginPage();
                            },
                          ),
                          (route) => false,
                        );
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
                      "Sign Up",
                      style: AppTextStyles.smallBodyText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: AppTextStyles.smallBodyText),
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
