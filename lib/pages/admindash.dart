import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:traceadmin/pages/add_transaction_page.dart';
import 'package:traceadmin/pages/transaction_listing_page.dart';
import 'package:traceadmin/pages/widgets/chart.dart';
import 'package:traceadmin/pages/widgets/transactioncard.dart';



class Admindash extends StatefulWidget {
  const Admindash({super.key});

  @override
  State<Admindash> createState() => _AdmindashState();
}

class _AdmindashState extends State<Admindash> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Chart(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      TransactionCardAdmin(
                        iconPath: "assets/icons/fuel.svg",
                        title: "Sana Travels",
                        amount: 5000,
                        reason: "Fuel Charge",
                        date: "16 Dec 2024",
                      ),
                      TransactionCardAdmin(
                        iconPath: "assets/icons/ticket.svg",
                        title: "Sana AC Bus",
                        amount: 2500,
                        reason: "Passenger Collection",
                        date: "16 Dec 2024",
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () { Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return AddTransactionPageAdmin();
                            },));},
                            child: Icon(Iconsax.add),

                          ),
                          ElevatedButton(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple)),
                              onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return TransactionListPageAdmin();
                            },));
                              }, child: Text('See All',))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
