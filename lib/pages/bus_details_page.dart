import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusDetailsPage extends StatefulWidget {
  final String busId;
  final String adminId;

  const BusDetailsPage({super.key, required this.busId, required this.adminId});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  Map<String, dynamic>? _busDetails;
  List<String> _busImages = [];
  int _passengerCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchBusDetails();
  }

  // ✅ Fetch Bus Details from Firestore
  Future<void> _fetchBusDetails() async {
    try {
      DocumentSnapshot busSnapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(widget.adminId)
          .collection("buses")
          .doc(widget.busId)
          .get();

      if (busSnapshot.exists) {
        Map<String, dynamic> busData = busSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _busDetails = busData;
          _passengerCount = busData["passengerCount"] ?? 0;
          _busImages = List<String>.from(busData["busImages"] ?? []);
        });
      }
    } catch (e) {
      print("🔥 Error fetching bus details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_busDetails?["name"] ?? "Bus Details")),
      body: _busDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Passenger Count
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.deepPurple),
                title: const Text("Passenger Count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("Current Passengers: $_passengerCount", style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Bus Images Section
            _busImages.isEmpty
                ? const Center(child: Text("No images available", style: TextStyle(fontSize: 16)))
                : _buildImageGallery(),
          ],
        ),
      ),
    );
  }

  // ✅ Bus Image Gallery
  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bus Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _busImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _busImages[index],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
