import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MoneyTransactionPage extends StatefulWidget {
  const MoneyTransactionPage({super.key});

  @override
  State<MoneyTransactionPage> createState() => _MoneyTransactionPageState();
}

class _MoneyTransactionPageState extends State<MoneyTransactionPage> {
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController driverPayController = TextEditingController();
  final TextEditingController helperPayController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController fitnessController = TextEditingController();
  final TextEditingController otherExpenseController = TextEditingController();

  double totalExpense = 0;
  double net = 0;

  void _calculate() {
    double revenue = double.tryParse(revenueController.text) ?? 0;
    double driver = double.tryParse(driverPayController.text) ?? 0;
    double helper = double.tryParse(helperPayController.text) ?? 0;
    double insurance = double.tryParse(insuranceController.text) ?? 0;
    double fitness = double.tryParse(fitnessController.text) ?? 0;
    double other = double.tryParse(otherExpenseController.text) ?? 0;

    double total = driver + helper + insurance + fitness + other;
    double profitLoss = revenue - total;

    setState(() {
      totalExpense = total;
      net = profitLoss;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("Money Transaction"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput("Total Revenue", Iconsax.money, revenueController),
            const SizedBox(height: 16),
            _buildInput("Driver Payment", Iconsax.user, driverPayController),
            const SizedBox(height: 16),
            _buildInput("Helper Payment", Iconsax.user_tag, helperPayController),
            const SizedBox(height: 16),
            _buildInput("Bus Insurance", Iconsax.shield_tick, insuranceController),
            const SizedBox(height: 16),
            _buildInput("Fitness Test", Iconsax.chart_1, fitnessController),
            const SizedBox(height: 16),
            _buildInput("Other Expenses", Iconsax.briefcase, otherExpenseController),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.calculator),
                label: const Text("Calculate"),
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Summary
            if (totalExpense > 0 || revenueController.text.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💰 Total Expense: ₹${totalExpense.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text(
                    net >= 0
                        ? "✅ Profit: ₹${net.toStringAsFixed(2)}"
                        : "❌ Loss: ₹${net.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: net >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
