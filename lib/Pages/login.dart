import 'package:admin/Pages/bottomnavbar.dart';
import 'package:admin/Pages/forgotpassword.dart';
import 'package:admin/Pages/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../Common/text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
                TextFormField(
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
                TextFormField(
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
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => BottomNavPage(),), (route) => false,);
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
