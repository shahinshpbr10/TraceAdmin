import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Column(
        children: [
          // Curved AppBar
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              width: double.infinity,
              height: 180,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About Us",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo or Image
                  Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset("assets/images/logo.png", fit: BoxFit.contain), // Update your logo
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Trace Admin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D5AFE),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Version 1.0.0",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Trace Admin is a powerful bus management tool built for real-time tracking, route planning, and team coordination. We aim to simplify fleet operations for schools, companies, and public transport providers through smart automation.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Our Mission",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "To empower bus owners and operators with intelligent tools for managing buses, drivers, schedules, and passengers efficiently.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Contact Us",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Email: support@traceadmin.com"),
                  const SizedBox(height: 4),
                  const Text("Phone: +91 9876543210"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Curved AppBar Clipper
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
