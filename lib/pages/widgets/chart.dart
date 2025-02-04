import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({Key? key}) : super(key: key);

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
              sections: paiChartSelectionData,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "₹ 25K",
                style: TextStyle(
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
}

List<PieChartSectionData> paiChartSelectionData = [
  PieChartSectionData(
    color: Colors.deepPurple,
    value: 30,
    showTitle: false,
    radius: 50,
  ),
  PieChartSectionData(
    color: Colors.orangeAccent,
    value: 20,
    showTitle: false,
    radius: 45,
  ),
  PieChartSectionData(
    color: Colors.teal,
    value: 15,
    showTitle: false,
    radius: 40,
  ),
  PieChartSectionData(
    color: Colors.blueAccent,
    value: 20,
    showTitle: false,
    radius: 35,
  ),
  PieChartSectionData(
    color: Colors.redAccent.withOpacity(0.5),
    value: 15,
    showTitle: false,
    radius: 30,
  ),
];
