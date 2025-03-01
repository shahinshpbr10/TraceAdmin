import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bus_details_page.dart';

class BusListingPage extends StatefulWidget {
  const BusListingPage({super.key});

  @override
  State<BusListingPage> createState() => _BusListingPageState();
}

class _BusListingPageState extends State<BusListingPage> {
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch logged-in Admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Listing")),
      body: _adminId == null
          ? const Center(child: CircularProgressIndicator()) // Show loader if admin ID is not yet available
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("admins")
            .doc(_adminId)
            .collection("buses")
            .snapshots(), // ✅ Real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No buses available."));
          }

          List<Map<String, dynamic>> buses = snapshot.data!.docs
              .map((doc) => {"busId": doc.id, ...doc.data() as Map<String, dynamic>})
              .toList();

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              var bus = buses[index];
              return _buildBusCard(bus);
            },
          );
        },
      ),
    );
  }

  // ✅ Bus Card UI
  Widget _buildBusCard(Map<String, dynamic> bus) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(bus['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(bus['name'] ?? "Unknown Bus", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Route: ${bus['route'] ?? "N/A"} | Plate: ${bus['numberPlate'] ?? "N/A"}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (bus["busId"] == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Error: Bus ID missing"),
              backgroundColor: Colors.red,
            ));
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusDetailsPage(busId: bus['busId'], adminId: _adminId!),
            ),
          );
        },
      ),
    );
  }
}
