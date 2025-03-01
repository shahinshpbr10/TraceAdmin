import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AdminBankingPage extends StatefulWidget {
  const AdminBankingPage({super.key});

  @override
  State<AdminBankingPage> createState() => _AdminBankingPageState();
}

class _AdminBankingPageState extends State<AdminBankingPage> {
  final _formKey = GlobalKey<FormState>();

  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiIdController = TextEditingController();

  String? _adminId;
  String? _qrData;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAdminId();
  }

  // ✅ Fetch logged-in Admin ID
  Future<void> _fetchAdminId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _adminId = currentUser.uid;
      });
      _fetchBankingDetails();
    }
  }

  // ✅ Fetch existing banking details from Firestore
  Future<void> _fetchBankingDetails() async {
    if (_adminId == null) return;

    try {
      DocumentSnapshot bankingSnapshot =
      await _firestore.collection("admins").doc(_adminId).collection("bankingDetails").doc("paymentInfo").get();

      if (bankingSnapshot.exists) {
        Map<String, dynamic> data = bankingSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _accountNumberController.text = data["accountNumber"] ?? "";
          _ifscController.text = data["ifsc"] ?? "";
          _upiIdController.text = data["upiId"] ?? "";
          _qrData = data["qrData"] ?? "";
        });
      }
    } catch (e) {
      print("🔥 Error fetching banking details: $e");
    }
  }

  // ✅ Save banking details to Firestore and generate QR
  Future<void> _saveBankingDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String qrContent = "upi://pay?pa=${_upiIdController.text.trim()}&pn=AdminPayment&am=0&cu=INR";

    Map<String, dynamic> bankingData = {
      "accountNumber": _accountNumberController.text.trim(),
      "ifsc": _ifscController.text.trim(),
      "upiId": _upiIdController.text.trim(),
      "qrData": qrContent,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection("admins").doc(_adminId).collection("bankingDetails").doc("paymentInfo").set(bankingData);

      setState(() {
        _qrData = qrContent;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Banking details updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Firestore error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving details: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Banking & QR Code")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_accountNumberController, "Account Number", Icons.account_balance),
              const SizedBox(height: 15),
              _buildTextField(_ifscController, "IFSC Code", Icons.code),
              const SizedBox(height: 15),
              _buildTextField(_upiIdController, "UPI ID", Icons.payment),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveBankingDetails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Save & Generate QR",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              if (_qrData != null && _qrData!.isNotEmpty) _buildQrCodeSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ QR Code Section
  Widget _buildQrCodeSection() {
    return Column(
      children: [
        const Text("Scan to Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        QrImageView(
          data: _qrData!,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          "UPI ID: ${_upiIdController.text}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ✅ Reusable Text Field
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }
}
