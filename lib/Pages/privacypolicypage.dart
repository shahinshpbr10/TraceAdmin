import 'package:admin/Common/text_styles.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
              height: 160,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Privacy Policy",
                  style: AppTextStyles.smallBodyText.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    "Introduction",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and protect your information.",
                 style: AppTextStyles.smallBodyText, ),
                  SizedBox(height: 20),

                  Text(
                    "What Information We Collect",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We may collect personal details such as your name, email, phone number, and address. This data is collected when you register, update your profile, or use certain features of the app.",
                  style: AppTextStyles.smallBodyText,),
                  SizedBox(height: 20),

                  Text(
                    "How We Use Your Data",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We use your data to provide a better experience, improve our services, send notifications, and for legal compliance.",
                 style: AppTextStyles.smallBodyText, ),
                  SizedBox(height: 20),

                  Text(
                    "Data Security & Storage",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your data is securely stored and encrypted. We do not sell or share your data with third parties unless required by law.",
                  style: AppTextStyles.smallBodyText,),
                  SizedBox(height: 20),

                  Text(
                    "Your Rights",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You have the right to view, update, or delete your personal information at any time. Contact us for any assistance regarding your privacy.",
                 style: AppTextStyles.smallBodyText, ),
                  SizedBox(height: 20),

                  Text(
                    "Contact Us",
                    style: AppTextStyles.smallBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "If you have any questions about this Privacy Policy, you can reach out to our support team at support@traceadmin.com.",
                 style: AppTextStyles.smallBodyText, ),
                  SizedBox(height: 20),
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
