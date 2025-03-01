import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _adminName = "Loading...";
  List<Map<String, dynamic>> _buses = [];
  List<Map<String, dynamic>> _workers = [];
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch Logged-in Admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid;
      });
      _fetchAdminData();
      _fetchBuses();
      _fetchWorkers();
    }
  }

  // ✅ Fetch Admin Username from Firestore
  Future<void> _fetchAdminData() async {
    if (_adminId == null) return;
    try {
      DocumentSnapshot adminSnapshot =
      await FirebaseFirestore.instance.collection("admins").doc(_adminId).get();
      if (adminSnapshot.exists) {
        setState(() {
          _adminName = adminSnapshot["name"] ?? "Admin";
        });
      }
    } catch (e) {
      print("🔥 Error fetching admin data: $e");
    }
  }

  // ✅ Fetch Buses from Firestore (Admins Collection → Buses Sub-Collection)
  Future<void> _fetchBuses() async {
    if (_adminId == null) return;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(_adminId)
          .collection("buses")
          .get();
      setState(() {
        _buses = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("🔥 Error fetching buses: $e");
    }
  }

  // ✅ Fetch Workers from Firestore (Admins Collection → Workers Sub-Collection)
  Future<void> _fetchWorkers() async {
    if (_adminId == null) return;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(_adminId)
          .collection("workers")
          .get();
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
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _sectionTitle("Revenue Details"),
            Chart(),
            _sectionTitle("Available Buses"),
            _buildCardContainer(
              children: [
                ..._buses.take(2).map((bus) => _buildBusCard(bus)).toList(),
                _buildActionButtons(() => _navigateTo(AddBusPage()), () => _navigateTo(BusListingPage())),
              ],
            ),
            _sectionTitle("Available Workers"),
            _buildCardContainer(
              children: [
                ..._workers.take(2).map((worker) => _buildWorkerCard(worker)).toList(),
                _buildActionButtons(() => _navigateTo(AddWorkerPage()), () => _navigateTo(WorkerListingPage())),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔹 Modern Header UI
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 230,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.menu, color: Colors.black),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          child: Text(
            'Hello,\n$_adminName 👋',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // 🔹 Section Title UI
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  // 🔹 Reusable Card Container
  Widget _buildCardContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  // 🔹 Bus Card UI
  Widget _buildBusCard(Map<String, dynamic> bus) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(bus['imageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(bus['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Route: ${bus['route']} | Plate: ${bus['numberPlate']}'),
      ),
    );
  }

  // 🔹 Worker Card UI
  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(worker['profilePicUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(worker['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Role: ${worker['workerType']}'),
      ),
    );
  }

  // 🔹 Action Buttons (Add & See All)
  Widget _buildActionButtons(VoidCallback onAdd, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Iconsax.add), label: const Text("Add")),
        TextButton(onPressed: onSeeAll, child: const Text("See All →")),
      ],
    );
  }

  // Navigation Helper
  void _navigateTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
