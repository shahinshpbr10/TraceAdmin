import 'package:flutter/material.dart';

class TransactionCardAdmin extends StatelessWidget {
  const TransactionCardAdmin({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.amount,
    required this.reason,
    required this.date,
  }) : super(key: key);

  final String iconPath; // Path to the SVG icon
  final String title; // Transaction title (e.g., "Sana Travels")
  final double amount; // Amount involved in the transaction
  final String reason; // Reason for the transaction (e.g., "Fuel Charge")
  final String date; // Date of the transaction

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(),
                  ),
                  Text(
                    reason,
                    style: TextStyle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
            // Transaction Amount
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style:TextStyle()
            ),
          ],
        ),
      ),
    );
  }
}
