import 'package:admin/Pages/aboutpage.dart';
import 'package:admin/Pages/changepasswordpage.dart';
import 'package:admin/Pages/login.dart';
import 'package:admin/Pages/privacypolicypage.dart';
import 'package:admin/Pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              height: 160,
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Iconsax.setting, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                children: [
                  // Account Section
                  const Text(
                    "Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(Iconsax.user, "Profile", () {
                   Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                     return ProfilePage();
                   },));
                  }),
                  _buildSettingTile(Iconsax.password_check, "Change Password", () {
                    // Navigate to change password screen
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return ChangePasswordPage();
                    },));
                  }),

                  const SizedBox(height: 24),

                  // App Info Section
                  const Text(
                    "App Info",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(Iconsax.security_safe, "Privacy Policy", () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return PrivacyPolicyPage();
                    },));
                  }),
                  _buildSettingTile(Iconsax.info_circle, "About", () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return AboutPage();
                    },));
                  }),

                  const SizedBox(height: 24),

                  // Logout
                  _buildSettingTile(
                    Iconsax.logout,
                    "Logout",
                        () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm Logout"),
                          content: const Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // close dialog
                                await FirebaseAuth.instance.signOut(); // Sign out the user

                                // Navigate to login screen
                               Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => LoginPage(),), (route) => false,);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5AFE),
                              ),
                              child: const Text("Logout"),
                            )
                          ],
                        ),
                      );
                    },
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        String? subtitle,
        Color iconColor = const Color(0xFF3D5AFE),
        Color textColor = Colors.black,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),

            // Title and optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            const Icon(Iconsax.arrow_right_34, size: 20, color: Colors.grey),
          ],
        ),
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
