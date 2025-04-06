import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class BusDetailsPage extends StatefulWidget {
  final String busId;
  final String busName;

  const BusDetailsPage({Key? key, required this.busId, required this.busName}) : super(key: key);

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  List<Map<String, String>> entryImageData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEntryImages();
  }

  Future<void> _fetchEntryImages() async {
    final storageRef = FirebaseStorage.instance.ref().child(widget.busId).child('entry');

    try {
      final ListResult result = await storageRef.listAll();
      final List<Map<String, String>> images = [];

      for (var ref in result.items) {
        final url = await ref.getDownloadURL();
        final metadata = await ref.getMetadata();
        final uploaded = metadata.timeCreated != null
            ? DateFormat('dd-MM-yyyy hh:mm a').format(metadata.timeCreated!.toLocal())
            : "Unknown";
        images.add({'url': url, 'uploadedAt': uploaded});
      }

      setState(() {
        entryImageData = images;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching entry images: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _shareImageFile(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/shared_image.jpg');
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Emergency! Please check this image.',
        );
      }
    } catch (e) {
      debugPrint("Error sharing file: $e");
    }
  }

  Future<void> _shareAllImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      List<XFile> files = [];

      for (int i = 0; i < entryImageData.length; i++) {
        final response = await http.get(Uri.parse(entryImageData[i]['url']!));
        if (response.statusCode == 200) {
          final file = File('${tempDir.path}/shared_image_$i.jpg');
          await file.writeAsBytes(response.bodyBytes);
          files.add(XFile(file.path));
        }
      }

      if (files.isNotEmpty) {
        await Share.shareXFiles(files, text: 'Emergency! Please check these images.');
      }
    } catch (e) {
      debugPrint("Error sharing multiple files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        title: Text(widget.busName),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
        actions: [
          if (entryImageData.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.send_2),
              tooltip: "Send All to Authority",
              onPressed: _shareAllImages,
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Text(
              "Passenger Entry Images",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: entryImageData.isEmpty
                ? const Center(child: Text("No entry images found"))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: entryImageData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final image = entryImageData[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                image['url']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                },
                                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Uploaded: ${image['uploadedAt']}",
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _shareImageFile(image['url']!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red.withOpacity(0.85),
                            child: const Icon(Iconsax.send_2, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
