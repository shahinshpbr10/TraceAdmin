import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:traceadmin/pages/adminhome.dart';
import 'package:traceadmin/pages/bus_listing_page.dart';
import 'package:traceadmin/pages/passenger_tracking.dart';
import 'package:traceadmin/pages/settings_page.dart';
import 'package:traceadmin/pages/viewdocpage.dart';

class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({super.key});

  @override
  _AdminBottomNavBarState createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  int _currentIndex = 0;

  // Pages to navigate
  final List<Widget> _children = [
    const AdminHomePage(),
    BusDocumentsPage(),
    BusListingPage(),
     SettingsPage()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home, size: 26),
                activeIcon: Icon(Iconsax.home_1, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.document, size: 26),
                activeIcon: Icon(Iconsax.document_1, size: 28),
                label: 'Documents',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.scan, size: 26),
                activeIcon: Icon(Iconsax.scan_barcode, size: 28),
                label: 'QR',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.setting, size: 26),
                activeIcon: Icon(Iconsax.setting_2, size: 28),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
