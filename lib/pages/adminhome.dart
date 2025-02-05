import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:traceadmin/addbuspage.dart';
import 'package:traceadmin/pages/add_worker_page.dart';
import 'package:traceadmin/pages/buslisting_page.dart';
import 'package:traceadmin/pages/workers_listing_Page.dart';
import 'package:traceadmin/pages/widgets/chart.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _adminName = "Loading..."; // Dynamic Admin Username
  List<Map<String, dynamic>> _buses = [];
  List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
    _fetchBuses();
    _fetchWorkers();
  }

  // Fetch Admin Username from Firestore

  Future<void> _fetchAdminData() async {
    try {
      // Get the current logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("⚠️ No user logged in.");
        return;
      }

      String userId = currentUser.uid; // Get UID of logged-in admin

      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(userId) // Use logged-in user's UID to fetch their data
          .get();

      if (adminSnapshot.exists) {
        Map<String, dynamic> adminData = adminSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _adminName = adminData["name"] ?? "Admin";

        });


      } else {
        print("⚠️ Admin document not found for UID: $userId");
      }
    } catch (e) {
      print("🔥 Error fetching admin data: $e");
    }
  }


  // Fetch Buses from Firestore
  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("buses").get();

      setState(() {
        _buses = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("🔥 Error fetching buses: $e");
    }
  }

  // Fetch Workers from Firestore
  Future<void> _fetchWorkers() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("workers").get();

      setState(() {
        _workers = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("🔥 Error fetching workers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for a premium feel
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.menu, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: const NetworkImage(
                      'https://via.placeholder.com/150', // Replace with actual admin profile image URL if available
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 20,
                  child: Text(
                    'Hello,\n$_adminName', // Dynamic Admin Name
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Revenue Details
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Revenue Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Chart(),
            const SizedBox(height: 15),

            // Available Buses Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Available Buses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildCardContainer(
              children: [
                ..._buses.take(2).map((bus) => _buildBusCard(bus)).toList(),
                _buildActionButtons(
                  onAdd: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => AddBusPage()),
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => BusListingPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Available Workers Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Available Workers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildCardContainer(
              children: [
                ..._workers.take(2).map((worker) => _buildWorkerCard(worker)).toList(),
                _buildActionButtons(
                  onAdd: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => AddWorkerPage()),
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => WorkerListingPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Card Container for Sections
  Widget _buildCardContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(children: children),
      ),
    );
  }

  // Dynamic Bus Card
  Widget _buildBusCard(Map<String, dynamic> bus) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(bus['imageUrl'] ?? 'https://via.placeholder.com/150'),
      ),
      title: Text(bus['name']),
      subtitle: Text('Route: ${bus['route']} | Plate: ${bus['numberPlate']}'),
    );
  }

  // Dynamic Worker Card
  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(worker['profilePicUrl'] ?? 'https://via.placeholder.com/150'),
      ),
      title: Text(worker['name']),
      subtitle: Text('Role: ${worker['workerType']} | Bus: ${worker['busAssigned']}'),
    );
  }

  // Action Buttons (Add & See All)
  Widget _buildActionButtons({required VoidCallback onAdd, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Iconsax.add),
          label: const Text("Add"),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text("See All"),
        ),
      ],
    );
  }
}
