// Splash Screen
import 'package:flutter/material.dart';
import 'package:traceadmin/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150),
            SizedBox(height: 20),
            Text(
              'Trace Admin',
              style: TextStyle(
                  color: Color(0xff7D2AFF),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SofiaProBold'),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Manage • Track • Travel",
              style: TextStyle(
                  color: Color(0xff7D2AFF),
                  fontSize: 15,
                  fontFamily: 'SofiaProBold'),
            ),
          ],
        ),
      ),
    );
  }
}
