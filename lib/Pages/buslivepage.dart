import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BusLivePage extends StatelessWidget {
  const BusLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buses = [
      {
        'name': 'Bus KL58 A1234',
        'passengers': 36,
        'location': 'Perinthalmanna',
      },
      {
        'name': 'Bus KL10 B5678',
        'passengers': 28,
        'location': 'Manjeri',
      },
      {
        'name': 'Bus KL13 C7890',
        'passengers': 12,
        'location': 'Malappuram',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Column(
        children: [
          // Curved AppBar
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: 170,
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Live Buses",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Iconsax.map, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),

          // Search + Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search bus...",
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
                    onPressed: () {
                      // filter sheet
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bus Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
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
                      // Bus icon
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D5AFE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_bus,
                            color: Color(0xFF3D5AFE), size: 28),
                      ),
                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Iconsax.location,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  bus['location'],
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Passenger count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.user, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              "${bus['passengers']}",
                              style: const TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                          ],
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

// Curved AppBar Clipper
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
