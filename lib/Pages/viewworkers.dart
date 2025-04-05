import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ViewWorkersPage extends StatefulWidget {
  const ViewWorkersPage({super.key});

  @override
  State<ViewWorkersPage> createState() => _ViewWorkersPageState();
}

class _ViewWorkersPageState extends State<ViewWorkersPage> {
  final TextEditingController _searchController = TextEditingController();

  // Sample worker data (can be replaced with Firebase)
  List<Map<String, String>> workers = [
    {"name": "Ashik", "role": "Driver"},
    {"name": "Shamim", "role": "Helper"},
    {"name": "Rahim", "role": "Cleaner"},
    {"name": "Haneef", "role": "Driver"},
    {"name": "Suhail", "role": "Helper"},
  ];

  String? filterRole;

  void _showFilterSheet() {
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
              const Text(
                "Filter by Role",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Divider(),
              ListTile(
                title: const Text("All"),
                onTap: () {
                  setState(() => filterRole = null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Driver"),
                onTap: () {
                  setState(() => filterRole = "Driver");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Helper"),
                onTap: () {
                  setState(() => filterRole = "Helper");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Cleaner"),
                onTap: () {
                  setState(() => filterRole = "Cleaner");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> get filteredWorkers {
    String search = _searchController.text.toLowerCase();
    return workers.where((worker) {
      final matchesRole = filterRole == null || worker['role'] == filterRole;
      final matchesSearch =
      worker['name']!.toLowerCase().contains(search);
      return matchesRole && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("View Workers"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search + Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search workers...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
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
                    icon: const Icon(Iconsax.setting_4,
                        color: Color(0xFF3D5AFE)),
                    onPressed: _showFilterSheet,
                  ),
                ),
              ],
            ),
          ),

          // Worker List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = filteredWorkers[index];
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
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage("assets/images/worker.png"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker['name']!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              worker['role']!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_34, color: Colors.grey)
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
