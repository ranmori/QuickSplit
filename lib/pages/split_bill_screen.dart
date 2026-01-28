import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/history.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  // 1. State Variables
  double _totalBill = 0.0;
  int _peopleCount = 1;
  int _tipPercentage = 0;
  bool _isSaving = false;

  // Consistency color from your Signup Page
  final Color primaryPurple = const Color(0xFF8B00D0);

  // 2. Calculation Logic
  double get _perPersonAmount {
    if (_peopleCount <= 0) return 0.0;
    double tipTotal = _totalBill * (_tipPercentage / 100);
    return (_totalBill + tipTotal) / _peopleCount;
  }

  // 3. Firebase Save Logic
  Future<void> _saveBillToHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You must be logged in to save history", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
     await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'title': "Dinner Split",
      'totalAmount': "\$${(_totalBill + (_totalBill * _tipPercentage / 100)).toStringAsFixed(2)}",
      'subtotal': _totalBill,
      'tip': (_totalBill * _tipPercentage / 100),
      'tax': 0.0, // Add tax logic later if needed
      'peopleCount': _peopleCount,
      'perPersonAmount': _perPersonAmount,
      'dateTime': DateTime.now().toIso8601String(),
      'items': [], // Placeholder for individual items
    });
      _showSnackBar("Bill saved to history!");
    } catch (e) {
      _showSnackBar("Error saving: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Split It", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- RESULT CARD (Updated with Purple Theme) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: primaryPurple.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Per Person", 
                      style: TextStyle(
                        fontSize: 16, 
                        color: isDark ? Colors.grey[400] : Colors.grey[600]
                      )
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${_perPersonAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 48, 
                        fontWeight: FontWeight.bold, 
                        color: primaryPurple
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- BILL INPUT (Consistent with Signup Input) ---
              _buildLabel('Bill Total'),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "0.00",
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryPurple, width: 2),
                  ),
                ),
                onChanged: (value) => setState(() {
                  _totalBill = double.tryParse(value) ?? 0.0;
                }),
              ),
              const SizedBox(height: 24),

              // --- TIP SELECTOR ---
              _buildLabel('Select Tip'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [0, 10, 15, 20].map((percentage) {
                  bool isSelected = _tipPercentage == percentage;
                  return ChoiceChip(
                    label: Text("$percentage%"),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _tipPercentage = percentage),
                    selectedColor: primaryPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // --- PEOPLE COUNTER ---
              _buildLabel('Split Between'),
              Row(
                children: [
                  _buildRoundButton(
                    isDark: isDark,
                    icon: Icons.remove,
                    onTap: () { if (_peopleCount > 1) setState(() => _peopleCount--); },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "$_peopleCount ${_peopleCount == 1 ? 'Person' : 'People'}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildRoundButton(
                    isDark: isDark,
                    icon: Icons.add,
                    onTap: () => setState(() => _peopleCount++),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- SAVE BUTTON (Matches Signup Button Style) ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_totalBill > 0 && !_isSaving) ? _saveBillToHistory : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save to History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              // --- RESET BUTTON ---
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _totalBill = 0.0;
                    _peopleCount = 1;
                    _tipPercentage = 0;
                  }),
                  child: const Text("Reset All", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRoundButton({required bool isDark, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Icon(icon, color: primaryPurple),
        ),
      ),
    );
  }
}