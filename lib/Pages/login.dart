import 'package:admin/Pages/bottomnavbar.dart';
import 'package:admin/Pages/forgotpassword.dart';
import 'package:admin/Pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../Common/text_styles.dart';

class LoginPage extends StatelessWidget {
   LoginPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Name
                 Text(
                  "Trace Admin",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 8),
                 Text(
                  "Manage. Track. Travel.",
                  style: AppTextStyles.smallBodyText.copyWith(
                    fontSize: 16,
                    color: Color(0xFF6C7A96),
                  ),
                ),
                const SizedBox(height: 40),   SizedBox(
                  height: size.height * 0.15,
                  child: SvgPicture.asset(
                    'assets/Images/login.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Email TextField
                TextFormField(  controller: emailController,

                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Iconsax.direct_inbox),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password TextField
                TextFormField(  controller: passwordController,

                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Iconsax.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => ForgotPasswordPage(),
                      ));
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF3D5AFE)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter email and password")),
                        );
                        return;
                      }

                      try {
                        await _auth.signInWithEmailAndPassword(email: email, password: password);

                        // Navigate to BottomNavPage on success
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(builder: (context) => BottomNavPage()),
                              (route) => false,
                        );
                      } on FirebaseAuthException catch (e) {
                        String message = "Login failed";
                        if (e.code == 'user-not-found') {
                          message = "No user found for that email";
                        } else if (e.code == 'wrong-password') {
                          message = "Wrong password";
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
                      "Login",
                      style: AppTextStyles.smallBodyText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have a Ac?",
                      style: AppTextStyles.smallBodyText,
                    ),
                    GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => SignupPage(),
                            )),
                        child: Text(
                          "Create Account.",
                          style: AppTextStyles.smallBodyText
                              .copyWith(color: Color(0xFF3D5AFE)),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
