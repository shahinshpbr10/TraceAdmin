import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();

  // Mock worker list
  final List<String> drivers = ['Ashik', 'Haneef'];
  final List<String> helpers = ['Shamim', 'Suhail'];

  String? selectedDriver;
  String? selectedHelper;

  List<Map<String, dynamic>> routes = [];

  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController routePriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("Add Bus"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Bus image
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/images/bus.png"),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3D5AFE),
                    ),
                    child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField("Bus Name", Iconsax.bus, busNameController),
            const SizedBox(height: 16),
            _buildTextField("Number Plate", Iconsax.car, numberPlateController),
            const SizedBox(height: 16),

            // Role Assignment
            _buildDropdown("Assign Driver", drivers, selectedDriver, (val) {
              setState(() => selectedDriver = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown("Assign Helper", helpers, selectedHelper, (val) {
              setState(() => selectedHelper = val);
            }),
            const SizedBox(height: 24),

            // Routes Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Routes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField("Route Name", Iconsax.map, routeNameController),
            const SizedBox(height: 12),
            _buildTextField("Price", Iconsax.money, routePriceController,
                inputType: TextInputType.number),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  if (routeNameController.text.isNotEmpty &&
                      routePriceController.text.isNotEmpty) {
                    setState(() {
                      routes.add({
                        'name': routeNameController.text,
                        'price': routePriceController.text
                      });
                      routeNameController.clear();
                      routePriceController.clear();
                    });
                  }
                },
                icon: const Icon(Iconsax.add_circle),
                label: const Text("Add Route"),
              ),
            ),

            // Show Added Routes
            if (routes.isNotEmpty)
              Column(
                children: routes.map((route) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${route['name']} - ₹${route['price']}"),
                        IconButton(
                          icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                          onPressed: () {
                            setState(() => routes.remove(route));
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2),
                label: const Text("Save Bus"),
                onPressed: () {
                  // TODO: Save bus to Firebase or backend
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF3D5AFE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        icon: const Icon(Iconsax.arrow_down),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
