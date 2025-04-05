import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ViewBusesPage extends StatefulWidget {
  const ViewBusesPage({super.key});

  @override
  State<ViewBusesPage> createState() => _ViewBusesPageState();
}

class _ViewBusesPageState extends State<ViewBusesPage> {
  final TextEditingController _searchController = TextEditingController();

  // Example list of buses
  List<Map<String, dynamic>> allBuses = [
    {
      "name": "City Bus",
      "plate": "KL58 A1234",
      "driver": "Ashik",
      "helper": "Shamim",
      "image": "assets/images/bus.png"
    },
    {
      "name": "Metro Shuttle",
      "plate": "KL10 B5678",
      "driver": "Haneef",
      "helper": "Suhail",
      "image": "assets/images/bus.png"
    },
  ];

  String? filterDriver;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              const Text("Filter by Driver", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                title: const Text("All"),
                onTap: () {
                  setState(() => filterDriver = null);
                  Navigator.pop(context);
                },
              ),
              ...allBuses
                  .map((e) => e['driver'])
                  .toSet()
                  .map((driver) => ListTile(
                title: Text(driver),
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

  List<Map<String, dynamic>> get filteredBuses {
    String query = _searchController.text.toLowerCase();
    return allBuses.where((bus) {
      final matchesDriver = filterDriver == null || bus['driver'] == filterDriver;
      final matchesSearch = bus['name'].toLowerCase().contains(query) ||
          bus['plate'].toLowerCase().contains(query);
      return matchesDriver && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("All Buses"),
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
                    onPressed: _showFilterSheet,
                  ),
                ),
              ],
            ),
          ),

          // List of buses
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBuses.length,
              itemBuilder: (context, index) {
                final bus = filteredBuses[index];
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
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(bus['image']),
                      ),
                      const SizedBox(width: 16),

                      // Bus Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bus['plate'],
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              "Driver: ${bus['driver']} | Helper: ${bus['helper']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_34, color: Colors.grey),
                    ],
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
