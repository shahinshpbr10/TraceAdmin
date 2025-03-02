import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  int totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotalRevenue();
  }

  Future<void> _fetchTotalRevenue() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String adminId = currentUser.uid;
    int revenueSum = 0;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("admins")
          .doc(adminId)
          .collection("buses")
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        revenueSum += (data['revenue'] as num?)?.toInt() ?? 0; // ✅ Fix: Cast num to int
      }

      setState(() {
        totalRevenue = revenueSum;
      });
    } catch (e) {
      print("🔥 Error fetching revenue: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              sections: _generatePieSections(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹ $totalRevenue",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Total Revenue",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections() {
    if (totalRevenue == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          showTitle: false,
          radius: 50,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.deepPurple,
        value: totalRevenue * 0.3, // Example split
        showTitle: false,
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orangeAccent,
        value: totalRevenue * 0.2,
        showTitle: false,
        radius: 45,
      ),
      PieChartSectionData(
        color: Colors.teal,
        value: totalRevenue * 0.15,
        showTitle: false,
        radius: 40,
      ),
      PieChartSectionData(
        color: Colors.blueAccent,
        value: totalRevenue * 0.2,
        showTitle: false,
        radius: 35,
      ),
      PieChartSectionData(
        color: Colors.redAccent.withOpacity(0.5),
        value: totalRevenue * 0.15,
        showTitle: false,
        radius: 30,
      ),
    ];
  }
}
