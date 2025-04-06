import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Common/text_styles.dart';

class ViewBusesPage extends StatefulWidget {
  const ViewBusesPage({super.key});

  @override
  State<ViewBusesPage> createState() => _ViewBusesPageState();
}

class _ViewBusesPageState extends State<ViewBusesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? filterDriver;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  void _showFilterSheet(List<Map<String, dynamic>> allBuses) {
    final uniqueDrivers = allBuses.map((e) => e['driver']).toSet();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text("Filter by Driver", style: AppTextStyles.smallBodyText.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                title: Text("All", style: AppTextStyles.smallBodyText),
                onTap: () {
                  setState(() => filterDriver = null);
                  Navigator.pop(context);
                },
              ),
              ...uniqueDrivers.map((driver) => ListTile(
                title: Text(driver, style: AppTextStyles.smallBodyText),
                onTap: () {
                  setState(() => filterDriver = driver);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _applyFilterAndSearch(List<Map<String, dynamic>> buses) {
    String query = _searchController.text.toLowerCase();
    return buses.where((bus) {
      final matchesDriver = filterDriver == null || bus['driver'] == filterDriver;
      final matchesSearch = bus['name'].toLowerCase().contains(query) ||
          bus['numberPlate'].toLowerCase().contains(query);
      return matchesDriver && matchesSearch;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> _busStream() {
    return FirebaseFirestore.instance
        .collection('busOwners')
        .doc(uid)
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: Text("All Buses", style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: AppTextStyles.smallBodyText,
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search by name or plate...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Iconsax.setting_4, color: Color(0xFF3D5AFE)),
                    onPressed: () {
                      // open sheet only after stream has loaded
                      FirebaseFirestore.instance
                          .collection('busOwners')
                          .doc(uid)
                          .collection('buses')
                          .get()
                          .then((snapshot) {
                        final buses = snapshot.docs.map((doc) => doc.data()).toList();
                        _showFilterSheet(List<Map<String, dynamic>>.from(buses));
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Firebase Bus List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _busStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No buses found"));
                }

                final filtered = _applyFilterAndSearch(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final bus = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Bus Image
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: bus['image'] != null
                                ? NetworkImage(bus['image'])
                                : const AssetImage("assets/bus.png") as ImageProvider,
                          ),
                          const SizedBox(width: 16),

                          // Bus Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bus['name'] ?? '',
                                  style: AppTextStyles.smallBodyText.copyWith(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bus['numberPlate'] ?? '',
                                  style: AppTextStyles.smallBodyText
                                      .copyWith(fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  "Driver: ${bus['driver']} | Helper: ${bus['helper']}",
                                  style:
                                  AppTextStyles.smallBodyText.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Iconsax.arrow_right_34, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
