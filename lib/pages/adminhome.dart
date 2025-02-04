import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:traceadmin/pages/add_transaction_page.dart';
import 'package:traceadmin/pages/add_worker_page.dart';
import 'package:traceadmin/pages/transaction_listing_page.dart';
import 'package:traceadmin/pages/widgets/bus_card.dart';
import 'package:traceadmin/pages/widgets/chart.dart';
import 'package:traceadmin/pages/widgets/worker_card.dart';
import 'package:traceadmin/pages/workers_listing_Page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for a premium feel
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      // Open menu or settings
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.menu, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: const NetworkImage(
                      'https://via.placeholder.com/150', // Replace with actual profile image URL
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 20,
                  child: const Text(
                    'Hello,\nShahinsh Pbr',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Revenue Details
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Revenue Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Chart(),
            const SizedBox(height: 15),

            // Available Buses Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Available Buses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildCardContainer(
              children: [
                buildBusCard("PTB", "MLTR-CAL", "Kl50 Q 5252"),
                buildBusCard("Sana Travels", "PLKD-MLTR", "Kl25 F 2235"),
                _buildActionButtons(
                  onAdd: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => AddTransactionPageAdmin()),
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => TransactionListPageAdmin()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Available Workers Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Available Workers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildCardContainer(
              children: [
                buildWorkerCard("Shamil", "Driver"),
                buildWorkerCard("Rahul", "Conductor"),
                _buildActionButtons(
                  onAdd: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => AddWorkerPage()),
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => WorkerListingPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Card Container for Sections
  Widget _buildCardContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(children: children),
      ),
    );
  }

  // Action Buttons (Add & See All)
  Widget _buildActionButtons({required VoidCallback onAdd, required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Add Button
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Iconsax.add, color: Colors.white),
            label: const Text(
              "Add",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // See All Button
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              backgroundColor: Colors.purple.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "See All",
              style: TextStyle(color: Colors.deepPurple, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
