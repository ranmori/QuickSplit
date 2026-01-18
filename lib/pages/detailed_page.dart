import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/split_record.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import '../widgets/section_header.dart';
import '../widgets/person_input.dart';
import '../widgets/item_tile.dart';
import '../widgets/custom_text_field.dart';
import 'split_summary.dart';


class DetailedSplitPage extends StatefulWidget {
    final Function(SplitRecord record) onRecordAdded;
    const DetailedSplitPage({super.key, required this.onRecordAdded});

  @override
  State<DetailedSplitPage> createState() => _DetailedSplitPageState();
}

class _DetailedSplitPageState extends State<DetailedSplitPage> {
  // State variables
  final List<TextEditingController> _peopleControllers = [
    TextEditingController(text: 'Person 1'),
    TextEditingController(text: 'Person 2'),
  ];
  
  final List<Map<String, dynamic>> _addedItems = [];
  final TextEditingController _taxController = TextEditingController(text: "0.0");
  final TextEditingController _tipController = TextEditingController(text: "15.0");
  bool _isTipPercentage = true;

  // --- ACTIONS ---

  void _addPerson() {
    setState(() {
      _peopleControllers.add(TextEditingController(text: 'Person ${_peopleControllers.length + 1}'));
    });
  }

  void _removePerson(int index) {
    if (_peopleControllers.length > 1) {
      setState(() {
        _peopleControllers.removeAt(index);
      });
    }
  }


  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String? localSelectedPerson;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Item Name"),
                    _buildDialogField(nameController, "e.g. Pizza"),
                    const SizedBox(height: 12),
                    _buildLabel("Price"),
                    _buildDialogField(priceController, "0.00", isNumber: true),
                    const SizedBox(height: 16),
                    _buildLabel("Assign to"),
                    const SizedBox(height: 8),
                    // Dynamic selectable list
                    SizedBox(
                      height: 150,
                      child: ListView(
                        shrinkWrap: true,
                        children: _peopleControllers.map((person) {
                          bool isSelected = localSelectedPerson == person.text;
                          return InkWell(
                            onTap: () => setDialogState(() => localSelectedPerson = person.text),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? const Color(0xFF00AB47) : Colors.grey.shade300),
                                color: isSelected ? const Color(0xFF00AB47).withValues(alpha: .05) : Colors.white,
                              ),
                              child: Text(person.text),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AB47),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                            setState(() {
                              _addedItems.add({
                                'name': nameController.text,
                                'price': priceController.text,
                                'assigned': localSelectedPerson ?? "Everyone",
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Add Item", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detailed Split', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B00D0),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: "People", onAdd: _addPerson),
                  ..._peopleControllers.asMap().entries.map((e) => PersonInput(
                        controller: e.value,
                        onDelete: () => _removePerson(e.key),
                      )),
                  const SizedBox(height: 24),
                  SectionHeader(title: "Items", onAdd: _showAddItemDialog),
                  if (_addedItems.isEmpty) 
                    _buildEmptyStatePlaceholder("No items added yet") 
                  else 
                    ..._addedItems.map((item) => ItemTile(item: item)),
                  const SizedBox(height: 24),
                  _buildLabel("Tax (\$)"),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _taxController, hintText: "0.0", keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ _buildLabel("Tip"), _buildTipToggle() ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _tipController, hintText: "15.0", keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (){
                  if(_addedItems.isEmpty) return;


                  // calcaulate the subtotal

                 double subtotal = 0;
  for (var item in _addedItems) {
                    subtotal +=
                        double.tryParse(item['price'].toString()) ?? 0.0;
                  }

                  // 2. Calculate Tax and Tip
                  double tax = double.tryParse(_taxController.text) ?? 0.0;
                  double tipInput = double.tryParse(_tipController.text) ?? 0.0;
                  // Assuming _isTipPercentage is a boolean you have for the toggle
                  double tip = _isTipPercentage
                      ? (subtotal * (tipInput / 100))
                      : tipInput;
                  double total = subtotal + tax + tip;

                  // 3. Advanced Split Logic (Calculating per person)
                  Map<String, double> individualTotals = {};

                  // Initialize every person with $0
                  for (var controller in _peopleControllers) {
                    individualTotals[controller.text] = 0.0;
                  }

                  for (var item in _addedItems) {
                    double itemPrice =
                        double.tryParse(item['price'].toString()) ?? 0.0;
                    String assigned = item['assigned'];

                    if (assigned == "Everyone") {
                      // Split the item price equally among all people
                      double splitShare = itemPrice / _peopleControllers.length;
                      individualTotals.updateAll(
                        (name, currentVal) => currentVal + splitShare,
                      );
                    } else {
                      // Add the full item price to the specific person
                      individualTotals[assigned] =
                          (individualTotals[assigned] ?? 0.0) + itemPrice;
                    }
                  }

                  // 4. Distribute Tax and Tip proportionally based on subtotal share
                  if (subtotal > 0) {
                    double extraCharges = tax + tip;
                    individualTotals.updateAll((name, personalSubtotal) {
                      double proportion = personalSubtotal / subtotal;
                      return personalSubtotal + (extraCharges * proportion);
                    });
                  }

                  // 5. Create the Summary Data Object
                  final summary = SplitSummaryData(
                    subtotal: subtotal,
                    tax: tax,
                    tip: tip,
                    total: total,
                    items: _addedItems,
                    individualTotals: individualTotals,
                    dateString: "Jan 18, 2026, 8:08 PM", people: [],
                  );


                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitSummaryScreen(data: summary),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _addedItems.isEmpty ? const Color(0xFFD9DEE3) : const Color(0xFF00AB47),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Calculate Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54));

  Widget _buildDialogField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00AB47))),
      ),
    );
  }

  Widget _buildTipToggle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _buildToggleButton("%", _isTipPercentage),
          _buildToggleButton("\$", !_isTipPercentage),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isTipPercentage = label == "%"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isActive ? const Color(0xFF00AB47) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
Widget _buildEmptyStatePlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
      ),
    );
  }