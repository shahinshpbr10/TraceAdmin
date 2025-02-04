import 'package:flutter/material.dart';
import 'package:traceadmin/pages/widgets/transactioncard.dart';

class TransactionListPageAdmin extends StatefulWidget {
  const TransactionListPageAdmin({Key? key}) : super(key: key);

  @override
  State<TransactionListPageAdmin> createState() =>
      _TransactionListPageState();
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("All Transactions"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
              child: Text(
                "No transactions available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];

                if (!_matchesSearch(transaction)) {
                  return Container(); // Hide items that don't match the search query
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TransactionCardAdmin(
                    iconPath: transaction["iconPath"],
                    title: transaction["title"],
                    amount: (transaction["amount"] as int).toDouble(),
                    reason: transaction["reason"],
                    date: transaction["date"],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(Map<String, dynamic> transaction) {
    return transaction["title"]
        .toLowerCase()
        .contains(_searchQuery) ||
        transaction["reason"]
            .toLowerCase()
            .contains(_searchQuery);
  }
}
