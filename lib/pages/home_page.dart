
import 'package:flutter/material.dart';
import 'package:traceadmin/main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          ListTile(
            title: Text('Revenue Tracking'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RevenueScreen()),
            ),
          ),
          ListTile(
            title: Text('Manage Workers'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WorkersScreen()),
            ),
          ),
          ListTile(
            title: Text('Passenger Tracking'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PassengerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}


// Revenue Screen
class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Revenue Tracking')),
      body: Center(child: Text('Revenue Details Here')),
    );
  }
}

// Workers Management Screen
class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Workers')),
      body: Center(child: Text('Worker Management Here')),
    );
  }
}

// Passenger Tracking Screen
class PassengerScreen extends StatelessWidget {
  const PassengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Passenger Tracking')),
      body: Center(child: Text('Passenger Data Here')),
    );
  }
}
