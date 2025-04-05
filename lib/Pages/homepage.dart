import 'package:admin/Common/text_styles.dart';
import 'package:admin/Pages/addbuspage.dart';
import 'package:admin/Pages/addworkerts%20page.dart';
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
  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser!.uid;
    _userFuture = _firestore.collection('busOwners').doc(uid).get();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['name'] ?? "User";
          final profilePic = userData['profilePic'] ?? ""; // Make sure this is a valid URL or path

          return buildHomeUI(context, username, profilePic);
        },
      ),
    );
  }
}

// Custom clipper for curved app bar
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
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

  const _LegendItem({required this.color, required this.label, Key? key})
      : super(key: key);

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
Widget buildHomeUI(BuildContext context, String username, String profilePic) {
  return Column(
    children: [
      // Top curved app bar
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
                style:  AppTextStyles.smallBodyText.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Welcome back to Trace Admin",
                style:AppTextStyles.smallBodyText.copyWith (
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),

      // Body content below app bar
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                    // Header with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: [ const Icon(Iconsax.chart5, color: Color(0xFF3D5AFE)),
                            const SizedBox(width: 8),
                            Text(
                              "Revenue Summary",
                              style: AppTextStyles.smallBodyText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text("View All",style: AppTextStyles.caption,),

                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pie Chart
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
                              titleStyle:  AppTextStyles.smallBodyText.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFFFFA726),
                              value: 30,
                              title: '30%',
                              radius: 50,
                              titleStyle:  AppTextStyles.smallBodyText.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFF66BB6A),
                              value: 30,
                              title: '30%',
                              radius: 50,
                              titleStyle: AppTextStyles.smallBodyText.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legend
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
              ),


              const SizedBox(height: 20),

              // My Bus Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
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
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [Color(0xFF3D5AFE), Color(0xFF7986CB)],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:  [
                          Row(
                            children: [
                              Image(image: AssetImage('assets/bus.png'),color: Colors.white,width: 30,),
                              SizedBox(width: 8),
                              Text(
                                "My Bus",
                                style: AppTextStyles.smallBodyText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text("view all",style: AppTextStyles.caption.copyWith(color: Colors.white),)

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Total Buses: 6", style: TextStyle(fontSize: 14)),
                              SizedBox(height: 4),
                              Text("Active Today: 4", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          IconButton(onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return AddBusPage();
                            },));
                          }, icon: Icon(Iconsax.additem))
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
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
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [Color(0xFF3D5AFE), Color(0xFF7986CB)],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:  [

                          Row(

                            children: [ Icon(Icons.people_alt, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "My Workers",
                                style:AppTextStyles.smallBodyText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return ViewWorkersPage();
                            },));
                          },
                              child: Text("View all",style: AppTextStyles.caption.copyWith(color: Colors.white),))
                        ],
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              Text("Total Staff: 12", style: TextStyle(fontSize: 14)),
                              SizedBox(height: 4),
                              Text("Drivers: 6", style: AppTextStyles.smallBodyText.copyWith(fontSize: 14)),
                              Text("Helpers: 6", style: AppTextStyles.smallBodyText.copyWith(fontSize: 14)),
                            ],
                          ),

                          IconButton(onPressed: () {
Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
  return AddWorkerPage();
},));
                          }, icon: Icon(Iconsax.additem))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    ],
  );
}