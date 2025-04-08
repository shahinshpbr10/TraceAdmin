import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

class ViewRevenuePage extends StatefulWidget {
  const ViewRevenuePage({super.key});

  @override
  State<ViewRevenuePage> createState() => _ViewRevenuePageState();
}

class _ViewRevenuePageState extends State<ViewRevenuePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> transactions = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('busOwners')
        .doc(uid)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'event': data['type'],
          'date': (data['createdAt'] as Timestamp).toDate().toIso8601String().split('T')[0],
          'revenue': 0.0,
          'expense': data['amount'] * 1.0,
        };
      }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              const Text("Filter by Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ...transactions
                  .map((e) => e['date'])
                  .toSet()
                  .map((date) => ListTile(
                title: Text(date),
                onTap: () {
                  setState(() => selectedDate = date);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                title: const Text("Clear Filter"),
                onTap: () {
                  setState(() => selectedDate = null);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get filteredTransactions {
    final query = _searchController.text.toLowerCase();
    return transactions.where((txn) {
      final matchDate = selectedDate == null || txn['date'] == selectedDate;
      final matchSearch = txn['event'].toLowerCase().contains(query);
      return matchDate && matchSearch;
    }).toList();
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
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              color: const Color(0xFF3D5AFE),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Revenue Overview",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Icon(Iconsax.graph, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search event...",
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Graphical Overview",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: filteredTransactions.asMap().entries.map((entry) {
                    int x = entry.key;
                    final tx = entry.value;
                    return BarChartGroupData(x: x, barRods: [
                      BarChartRodData(toY: tx['revenue'], color: Colors.green, width: 14),
                      BarChartRodData(toY: tx['expense'], color: Colors.red, width: 14),
                    ]);
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int index = value.toInt();
                          if (index < filteredTransactions.length) {
                            return Text(
                              filteredTransactions[index]['event'],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  groupsSpace: 20,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transaction Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['event'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text("📅 Date: ${tx['date']}", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text("💰 Revenue: ₹${tx['revenue']}", style: const TextStyle(color: Colors.green)),
                      Text("💸 Expenses: ₹${tx['expense']}", style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 4),
                      Text(
                        tx['revenue'] - tx['expense'] >= 0
                            ? "✅ Profit: ₹${(tx['revenue'] - tx['expense']).toStringAsFixed(2)}"
                            : "❌ Loss: ₹${(tx['expense'] - tx['revenue']).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: tx['revenue'] >= tx['expense'] ? Colors.green : Colors.red,
                        ),
                      ),
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