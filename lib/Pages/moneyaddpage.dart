import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> buses = [];
  List<Map<String, dynamic>> workers = [];

  String? selectedBus;
  String? selectedWorker;
  String? selectedType;
  DateTime selectedDate = DateTime.now();
  final TextEditingController amountController = TextEditingController();
  File? receiptFile;

  final List<String> expenseTypes = [
    'Diesel',
    'Worker Payment',
    'Insurance',
    'Maintenance',
    'Fitness',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final busSnap = await _firestore.collection('busOwners').doc(uid).collection('buses').get();
    final workerSnap = await _firestore.collection('busOwners').doc(uid).collection('workers').get();

    setState(() {
      buses = busSnap.docs.map((doc) {
        final data = doc.data();
        data['busId'] = doc.id;
        return data;
      }).toList();

      workers = workerSnap.docs.map((doc) {
        final data = doc.data();
        data['workerId'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _pickReceiptFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => receiptFile = File(result.files.single.path!));
    }
  }

  Future<void> _submitExpense() async {
    final uid = _auth.currentUser?.uid;
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (selectedBus == null || selectedWorker == null || selectedType == null || amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final expenseId = _firestore.collection('busOwners').doc(uid).collection('expenses').doc().id;
      String? receiptUrl;

      if (receiptFile != null) {
        final ref = _storage.ref().child('expenses/$uid/$expenseId/receipt.jpg');
        await ref.putFile(receiptFile!);
        receiptUrl = await ref.getDownloadURL();
      }

      final busDoc = buses.firstWhere((b) => b['name'] == selectedBus);
      final workerDoc = workers.firstWhere((w) => w['name'] == selectedWorker);

      final busId = busDoc['busId'];
      final workerId = workerDoc['workerId'];

      await _firestore.collection('busOwners').doc(uid).collection('expenses').doc(expenseId).set({
        'expenseId': expenseId,
        'busId': busId,
        'workerId': workerId,
        'type': selectedType,
        'amount': amount,
        'date': selectedDate.toIso8601String(),
        'receiptUrl': receiptUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5AFE),
        title: const Text("Add Expense"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _dropdown("Select Bus", buses.map((e) => e['name'].toString()).toList(), selectedBus,
                    (val) => setState(() => selectedBus = val)),
            const SizedBox(height: 16),
            _dropdown("Select Worker", workers.map((e) => e['name'].toString()).toList(), selectedWorker,
                    (val) => setState(() => selectedWorker = val)),
            const SizedBox(height: 16),
            _dropdown("Expense Type", expenseTypes, selectedType,
                    (val) => setState(() => selectedType = val)),
            const SizedBox(height: 16),
            _datePicker(),
            const SizedBox(height: 16),
            _textField("Amount", amountController, Iconsax.money),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickReceiptFile,
              icon: const Icon(Iconsax.document_upload),
              label: Text(receiptFile == null ? "Upload Receipt" : "Change Receipt"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitExpense,
                icon: const Icon(Iconsax.save_2),
                label: const Text("Save Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? selected, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<String>(
        value: selected,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2022),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            const Icon(Iconsax.calendar)
          ],
        ),
      ),
    );
  }
}
