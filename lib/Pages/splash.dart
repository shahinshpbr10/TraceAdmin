import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/placeholder');
    });
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
              width: size.width * 0.6,
              child: Lottie.asset(
                'assets/lottie/trace_bus_animation.json',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            // App Name
            const Text(
              "Trace Admin",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(
              "Manage. Track. Travel.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6C7A96),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
