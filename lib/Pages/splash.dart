import 'dart:async';
import 'package:admin/Pages/login.dart';
import 'package:admin/Pages/bottomnavbar.dart'; // or your home page
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../Common/text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _checkAuth);
  }

  void _checkAuth() {
    final user = _auth.currentUser;
    if (user != null) {
      // User is logged in
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => BottomNavPage()),
            (route) => false,
      );
    } else {
      // User is not logged in
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) =>  LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon or Lottie Animation
            SizedBox(
              height: size.height * 0.3,
              width: double.infinity,
              child: Lottie.asset(
                'assets/lottie/splash.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            // App Name
            Text(
              "Trace Admin",
              style: AppTextStyles.smallBodyText.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            Text(
              "Manage. Track. Travel.",
              style: AppTextStyles.smallBodyText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6C7A96),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
