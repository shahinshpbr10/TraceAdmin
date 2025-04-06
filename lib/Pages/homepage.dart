import 'package:admin/Common/text_styles.dart';
import 'package:admin/Pages/addbuspage.dart';
import 'package:admin/Pages/addworkerts%20page.dart';
import 'package:admin/Pages/moneyaddpage.dart';
import 'package:admin/Pages/viewbuspage.dart';
import 'package:admin/Pages/viewrevenupage.dart';
import 'package:admin/Pages/viewworkers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<DocumentSnapshot> _userFuture;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  int totalBuses = 0;
  int activeBuses = 0;
  int totalWorkers = 0;
  int driverCount = 0;
  int helperCount = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _firestore.collection('busOwners').doc(uid).get();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('No UID found. User might not be logged in.');
      return;
    }

    try {
      debugPrint('Fetching buses and workers for UID: $uid');

      final busSnapshot = await _firestore
          .collection('busOwners')
          .doc(uid)
          .collection('buses')
          .get();

      debugPrint('Total buses fetched: ${busSnapshot.size}');

      final workerSnapshot = await _firestore
          .collection('busOwners')
          .doc(uid)
          .collection('workers')
          .get();

      debugPrint('Total workers fetched: ${workerSnapshot.size}');

      int active = 0;
      for (var doc in busSnapshot.docs) {
        if (doc.data()['isActive'] == true) active++;
      }
      debugPrint('Active buses counted: $active');

      int drivers = 0;
      int helpers = 0;
      for (var doc in workerSnapshot.docs) {
        final role = doc.data()['role'];
        if (role == 'Driver') drivers++;
        if (role == 'Helper') helpers++;
      }

      debugPrint('Drivers: $drivers, Helpers: $helpers');

      setState(() {
        totalBuses = busSnapshot.size;
        activeBuses = active;
        totalWorkers = workerSnapshot.size;
        driverCount = drivers;
        helperCount = helpers;
      });

      debugPrint('Counts updated in state.');
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['name'] ?? "User";
          final profilePic = userData['profilePic'] ?? "";

          return buildHomeUI(context, username, profilePic);
        },
      ),
    );
  }

  Widget buildHomeUI(BuildContext context, String username, String profilePic) {
    return Column(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            height: 200,
            width: double.infinity,
            color: const Color(0xFF3D5AFE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.notification, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : const AssetImage('assets/b1.png') as ImageProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Hi, $username 👋",
                  style: AppTextStyles.smallBodyText.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Welcome back to Trace Admin",
                  style: AppTextStyles.smallBodyText.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPieChartSection(context),
                const SizedBox(height: 20),
                buildBusCard(context),
                const SizedBox(height: 20),
                buildWorkerCard(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPieChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.chart5, color: Color(0xFF3D5AFE)),
                  const SizedBox(width: 8),
                  Text("Revenue Summary",
                      style: AppTextStyles.smallBodyText.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => const ViewRevenuePage()));
                },
                child: Text("View All", style: AppTextStyles.caption),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => const AddExpensePage()));
                },
                icon: const Icon(Iconsax.additem),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF3D5AFE),
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: AppTextStyles.smallBodyText.copyWith(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFFA726),
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: AppTextStyles.smallBodyText.copyWith(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF66BB6A),
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: AppTextStyles.smallBodyText.copyWith(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _LegendItem(color: Color(0xFF3D5AFE), label: "Buses"),
              _LegendItem(color: Color(0xFFFFA726), label: "Workers"),
              _LegendItem(color: Color(0xFF66BB6A), label: "Others"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(colors: [Color(0xFF3D5AFE), Color(0xFF7986CB)]),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/bus.png'),
                      color: Colors.white,
                      width: 30,
                    ),
                    const SizedBox(width: 8),
                    Text("My Bus",
                        style: AppTextStyles.smallBodyText.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => const ViewBusesPage()));
                  },
                  child:
                  Text("view all", style: AppTextStyles.caption.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Buses: $totalBuses"),
                    Text("Active Today: $activeBuses"),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (_) => const AddBusPage()));
                    },
                    icon: const Icon(Iconsax.additem))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildWorkerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(colors: [Color(0xFF3D5AFE), Color(0xFF7986CB)]),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt, color: Colors.white),
                    const SizedBox(width: 8),
                    Text("My Workers",
                        style: AppTextStyles.smallBodyText.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => const ViewWorkersPage()));
                  },
                  child:
                  Text("View all", style: AppTextStyles.caption.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Staff: $totalWorkers",
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Drivers: $driverCount",
                        style:
                        AppTextStyles.smallBodyText.copyWith(fontSize: 14)),
                    Text("Helpers: $helperCount",
                        style:
                        AppTextStyles.smallBodyText.copyWith(fontSize: 14)),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (_) => const AddWorkerPage()));
                    },
                    icon: const Icon(Iconsax.additem))
              ],
            ),
          )
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
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.smallBodyText.copyWith(fontSize: 13)),
      ],
    );
  }
}