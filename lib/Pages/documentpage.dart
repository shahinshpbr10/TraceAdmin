import 'package:admin/Common/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final TextEditingController _searchController = TextEditingController();

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
            runSpacing: 10,
            children: [
              const Text(
                "Filter Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Iconsax.document),
                title: const Text("Bus Insurance"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Iconsax.document),
                title: const Text("Driver License"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Iconsax.document),
                title: const Text("Pollution Test"),
                onTap: () {},
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.filter),
                label: const Text("Apply Filter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<String> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.smallBodyText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),    GestureDetector(onTap: () {

            },
              child: Text(
                'View All',
                style:  AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // View document logic
              },
              child: Container(
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.document, size: 28, color: Color(0xFF3D5AFE)),
                    const SizedBox(height: 10),
                    Text(
                      docs[index],
                      style: AppTextStyles.smallBodyText.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Column(
        children: [
          // Curved AppBar
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text(
                    "Documents",
                    style:AppTextStyles.smallBodyText.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Iconsax.folder_open, color: Colors.white, size: 26),
                ],
              ),
            ),
          ),

          // Body content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  // Search bar + filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(style: AppTextStyles.smallBodyText,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search documents...",
                            prefixIcon: const Icon(Iconsax.search_normal),
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

                  // Document Sections
                  _buildSection("Bus Insurance", ["Insurance - KL58 2024.pdf"]),
                  _buildSection("Bus License", ["Bus License - KL58.pdf","Bus License - KL58.pdf"]),
                  _buildSection("Driver License", ["Driver - Ashik.pdf","Driver - Ashik.pdf"]),
                  _buildSection("Pollution Test", ["Smoke Test - KL58 Oct 2024","Smoke Test - KL58 Oct 2024"]),
                  _buildSection("Fitness Certificate", ["Fitness 2025 - KL58.pdf","Fitness 2025 - KL58.pdf"]),
                  _buildSection("Permit", ["All India Permit - 2024","All India Permit - 2024"]),
                  _buildSection("RC Book", ["RC Full - KL58.pdf","RC Full - KL58.pdf"]),
                  _buildSection("Road Tax", ["Tax Receipt 2024"]),
                  _buildSection("Service Record", ["Service Log Feb 2024"]),
                ],
              ),
            ),
          ),
        ],
      ),

      // Add document button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add document flow
        },
        backgroundColor: const Color(0xFF3D5AFE),
        icon: const Icon(Iconsax.add_circle,color: Colors.white,),
        label:  Text("Add Document",style: AppTextStyles.smallBodyText.copyWith(color: Colors.white),),
      ),
    );
  }
}

// Curved AppBar clipper
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
