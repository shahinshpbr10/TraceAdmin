import 'package:admin/Pages/livebusdetailspage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BusLivePage extends StatefulWidget {
  const BusLivePage({super.key});

  @override
  State<BusLivePage> createState() => _BusLivePageState();
}

class _BusLivePageState extends State<BusLivePage> {
  final databaseRef = FirebaseDatabase.instance.ref('buseslive');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> buses = [];
  Stream<DatabaseEvent>? _busStream;

  @override
  void initState() {
    super.initState();
    _busStream = databaseRef.onValue;
    _busStream!.listen((event) => _fetchLiveBuses(event.snapshot));
  }

  Future<void> _fetchLiveBuses(DataSnapshot snapshot) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || !snapshot.exists) return;

    final rawData = snapshot.value as Map<dynamic, dynamic>;
    List<Map<String, dynamic>> finalBuses = [];

    for (var entry in rawData.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      final busId = data['busID'];
      final busName = data['busName'];

      try {
        final busDoc = await _firestore
            .collection('busOwners')
            .doc(uid)
            .collection('buses')
            .where('busId', isEqualTo: busId)
            .where('name', isEqualTo: busName)
            .limit(1)
            .get();

        if (busDoc.docs.isNotEmpty) {
          final firestoreData = busDoc.docs.first.data();

          final entryLocation = data['entryLocations']?[data['entryCount']];
          final lat = entryLocation?['latitude'];
          final lng = entryLocation?['longitude'];

          final locationText = (lat != null && lng != null)
              ? 'Lat: $lat, Lng: $lng'
              : 'Location not available';

          finalBuses.add({
            'busID': busId,
            'name': busName,
            'numberPlate': data['numberPlate'] ?? '',
            'passengers': (data['entryCount'] ?? 0) - (data['exitCount'] ?? 0),
            'location': locationText,
            'image': firestoreData['image'] ?? '',
          });
        }
      } catch (e) {
        debugPrint('Error checking Firestore bus: $e');
      }
    }

    setState(() => buses = finalBuses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Column(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: 170,
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Live Buses", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Icon(Iconsax.map, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),
          Expanded(
            child: buses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => BusDetailsPage(
                        busId: bus['busID'],
                        busName: bus['name'],
                      ),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: bus['image'] != ''
                              ? Image.network(bus['image'], height: 48, width: 48, fit: BoxFit.cover)
                              : Container(
                            height: 48,
                            width: 48,
                            color: const Color(0xFF3D5AFE).withOpacity(0.1),
                            child: const Icon(Icons.directions_bus, color: Color(0xFF3D5AFE), size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bus['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Iconsax.location, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(bus['location'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.user, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text("${bus['passengers']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
