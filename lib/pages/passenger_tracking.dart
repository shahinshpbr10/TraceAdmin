import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PassengerTrackingApp extends StatefulWidget {
  @override
  _PassengerTrackingAppState createState() => _PassengerTrackingAppState();
}

class _PassengerTrackingAppState extends State<PassengerTrackingApp> {
  int _totalPassengers = 0;
  List<PassengerDetails> _passengerList = [];

  @override
  void initState() {
    super.initState();
    _listenToPassengerUpdates();
  }

  void _listenToPassengerUpdates() {
    FirebaseFirestore.instance
        .collection('bus_tracking')
        .doc('passenger_status')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _totalPassengers = snapshot.data()?['total_passengers'] ?? 0;

          // Parse passenger details
          Map<String, dynamic> passengersData =
              snapshot.data()?['passengers'] ?? {};

          _passengerList = passengersData.entries.map((entry) {
            return PassengerDetails(
              id: entry.key,
              timestamp: (entry.value['timestamp'] as Timestamp).toDate(),
              imageUrl: entry.value['image_url'],
            );
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Passenger Tracking'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Passenger Count Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    'Total Passengers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalPassengers',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Passenger List
          Expanded(
            child: _passengerList.isEmpty
                ? const Center(
              child: Text(
                "No Passengers Boarded Yet",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _passengerList.length,
              itemBuilder: (context, index) {
                final passenger = _passengerList[index];
                return _buildPassengerCard(passenger);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Passenger Card UI
  Widget _buildPassengerCard(PassengerDetails passenger) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: passenger.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
            const Icon(Icons.error, color: Colors.red),
          ),
        ),
        title: Text(
          'Passenger ${passenger.id}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Boarded at: ${DateFormat('hh:mm a, dd MMM yyyy').format(passenger.timestamp)}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.directions_bus, color: Colors.white70),
      ),
    );
  }
}

class PassengerDetails {
  final String id;
  final DateTime timestamp;
  final String imageUrl;

  PassengerDetails({
    required this.id,
    required this.timestamp,
    required this.imageUrl,
  });
}
