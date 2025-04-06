import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ViewWorkersPage extends StatefulWidget {
  const ViewWorkersPage({super.key});

  @override
  State<ViewWorkersPage> createState() => _ViewWorkersPageState();
}

class _ViewWorkersPageState extends State<ViewWorkersPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              const Text("Filter by Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ListTile(
                title: const Text("All"),
                onTap: () {
                  setState(() => filterRole = null);
                  Navigator.pop(context);
                },
              ),
              ...["Driver", "Helper", "Cleaner", "Other"].map((role) => ListTile(
                title: Text(role),
                onTap: () {
                  setState(() => filterRole = role);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getFilteredWorkersStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('busOwners')
        .doc(uid)
        .collection('workers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  List<Map<String, dynamic>> _applySearchAndFilter(List<Map<String, dynamic>> workers) {
    final search = _searchController.text.toLowerCase();

    return workers.where((worker) {
      final matchesSearch = worker['name']?.toLowerCase().contains(search) ?? false;
      final matchesRole = filterRole == null || worker['role'] == filterRole;
      return matchesSearch && matchesRole;
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
          // Search + Filter
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

          // Firebase Worker List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getFilteredWorkersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No workers found."));
                }

                final filtered = _applySearchAndFilter(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final worker = filtered[index];
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
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: worker['profileImage'] != null
                                ? NetworkImage(worker['profileImage'])
                                : const AssetImage("assets/b1.png") as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker['name'] ?? '',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  worker['role'] ?? '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Iconsax.arrow_right_34, color: Colors.grey)
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
