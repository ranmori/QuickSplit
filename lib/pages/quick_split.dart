import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/split_record.dart';

class QuickSplitPage extends StatefulWidget {
  final Function(SplitRecord record) onRecordAdded;
  const QuickSplitPage({super.key, required this.onRecordAdded});

  @override
  State<QuickSplitPage> createState() => _QuickSplitPageState();
}

class _QuickSplitPageState extends State<QuickSplitPage> {
  final TextEditingController _amountController = TextEditingController(text: "0.0");
  final TextEditingController _peopleController = TextEditingController(text: "2");
  final TextEditingController _taxController = TextEditingController(text: "0.0");
  
  double _tipPercentage = 0.15;
  double _splitAmount = 0.0;

  void _calculate() {
    double bill = double.tryParse(_amountController.text) ?? 0.0;
    int people = int.tryParse(_peopleController.text) ?? 1;
    double tax = double.tryParse(_taxController.text) ?? 0.0;
    
    if (people < 1) people = 1;

    double totalTip = bill * _tipPercentage;
    double totalWithExtras = bill + tax + totalTip;
    double perPerson = totalWithExtras / people;

    setState(() {
      _splitAmount = perPerson;
    });

    // --- ADD TO HISTORY LOGIC ---
    final newRecord = SplitRecord(
      id: DateTime.now().toString(),
      title: "Quick Split",
      totalAmount: "\$${totalWithExtras.toStringAsFixed(2)}",
      dateTime: "Just now",
      peopleCount: people,
      perPersonAmount: "\$${perPerson.toStringAsFixed(2)}",
      items: [
        {"name": "Base Bill", "price": bill.toString()},
        {"name": "Tax", "price": tax.toString()},
        {"name": "Tip", "price": totalTip.toStringAsFixed(2)},
      ],
      tax: tax,
      tip: totalTip,
      subtotal: bill,
    );

    widget.onRecordAdded(newRecord);
 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quick Split', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B00D0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Result Card
            _buildResultCard(),
            const SizedBox(height: 24),
            
            // Input Form Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: "Total Bill",
                      prefixIcon: Icons.attach_money,
                      controller: _amountController,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: "Number of People",
                      prefixIcon: Icons.person_outline,
                      controller: _peopleController,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: "Tax",
                      prefixIcon: Icons.receipt_long,
                      controller: _taxController,
                    ),
                    const SizedBox(height: 24),
                    const Text("Tip Percentage", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildTipSegmentedButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B00D0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Calculate Split', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF8B00D0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B00D0).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text("EACH PERSON PAYS", 
            style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)
          ),
          const SizedBox(height: 8),
          Text(
            "\$${_splitAmount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF8B00D0)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required IconData prefixIcon, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipSegmentedButton() {
    return SegmentedButton<double>(
      segments: const [
        ButtonSegment(value: 0.10, label: Text("10%")),
        ButtonSegment(value: 0.15, label: Text("15%")),
        ButtonSegment(value: 0.18, label: Text("18%")),
        ButtonSegment(value: 0.20, label: Text("20%")),
      ],
      selected: {_tipPercentage},
      onSelectionChanged: (Set<double> newSelection) {
        setState(() {
          _tipPercentage = newSelection.first;
        });
      },
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: const Color(0xFF8B00D0),
        selectedForegroundColor: Colors.white,
      ),
    );
  }
}