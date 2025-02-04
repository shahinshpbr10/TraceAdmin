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
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Transaction Icon
              CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                radius: 25,
                child: Image.asset(iconPath, width: 30, height: 30),
              ),
              const SizedBox(width: 12),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      reason,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction Amount
              Text(
                "₹${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
