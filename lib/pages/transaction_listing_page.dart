import 'package:flutter/material.dart';
import 'package:traceadmin/pages/widgets/transactioncard.dart';

class TransactionListPageAdmin extends StatefulWidget {
  const TransactionListPageAdmin({Key? key}) : super(key: key);

  @override
  State<TransactionListPageAdmin> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPageAdmin> {
  final List<Map<String, dynamic>> _transactions = [
    {
      "iconPath": "assets/icons/fuel.svg",
      "title": "Sana Travels",
      "amount": 5000,
      "reason": "Fuel Charge",
      "date": "16 Dec 2024",
    },
    {
      "iconPath": "assets/icons/ticket.svg",
      "title": "Sana AC Bus",
      "amount": 2500,
      "reason": "Passenger Collection",
      "date": "16 Dec 2024",
    },
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Transactions"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by title or reason...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _transactions
                  .where((transaction) =>
              transaction["title"]
                  .toLowerCase()
                  .contains(_searchQuery) ||
                  transaction["reason"]
                      .toLowerCase()
                      .contains(_searchQuery))
                  .map((transaction) {
                return TransactionCardAdmin(
                  iconPath: transaction["iconPath"],
                  title: transaction["title"],
                  amount: (transaction["amount"] as int).toDouble(), // Convert int to double here
                  reason: transaction["reason"],
                  date: transaction["date"],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
