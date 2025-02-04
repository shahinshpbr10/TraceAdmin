import 'package:flutter/material.dart';

class AddTransactionPageAdmin extends StatefulWidget {
  const AddTransactionPageAdmin({Key? key}) : super(key: key);

  @override
  State<AddTransactionPageAdmin> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPageAdmin> {
  final _formKey = GlobalKey<FormState>();

  String title = "";
  String reason = "";
  double amount = 0.0;
  String date = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Reason"),
                onChanged: (value) {
                  reason = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Date"),
                onChanged: (value) {
                  date = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logic to save the transaction
                    Navigator.pop(context);
                  }
                },
                child: Text("Add Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
