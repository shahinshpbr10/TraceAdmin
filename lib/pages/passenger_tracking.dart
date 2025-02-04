import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bus Passenger Tracking'),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            // Passenger Count Display
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.blue[100],
              child: Center(
                child: Text(
                  'Total Passengers: $_totalPassengers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Passenger List
            Expanded(
              child: ListView.builder(
                itemCount: _passengerList.length,
                itemBuilder: (context, index) {
                  final passenger = _passengerList[index];
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: passenger.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                    title: Text('Passenger ${passenger.id}'),
                    subtitle: Text(
                      'Boarded at: ${passenger.timestamp}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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