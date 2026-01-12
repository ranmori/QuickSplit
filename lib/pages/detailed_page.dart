import 'package:flutter/material.dart';

void main() {
  runApp(const DetailedSplitApp());
}

class DetailedSplitApp extends StatelessWidget {
  const DetailedSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8B00D0),
      ),
      home: const DetailedSplitPage(),
    );
  }
}

class DetailedSplitPage extends StatefulWidget {
  const DetailedSplitPage({super.key});

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

  void _calculateSplit() {
    if (_addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item first!")),
      );
      return;
    }

    double subtotal = 0;
    for (var item in _addedItems) {
      subtotal += double.tryParse(item['price'].toString()) ?? 0;
    }

    double tax = double.tryParse(_taxController.text) ?? 0;
    double tipInput = double.tryParse(_tipController.text) ?? 0;
    double totalTip = _isTipPercentage ? (subtotal * (tipInput / 100)) : tipInput;
    double grandTotal = subtotal + tax + totalTip;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Split Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subtotal: \$${subtotal.toStringAsFixed(2)}"),
            Text("Tax: \$${tax.toStringAsFixed(2)}"),
            Text("Tip: \$${totalTip.toStringAsFixed(2)}"),
            const Divider(),
            Text("Grand Total: \$${grandTotal.toStringAsFixed(2)}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00AB47))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
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
                  _buildSectionHeader("People", onAdd: _addPerson),
                  ..._peopleControllers.asMap().entries.map((e) => _buildListInput(e.value, () => _removePerson(e.key))),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Items", onAdd: _showAddItemDialog),
                  if (_addedItems.isEmpty) 
                    _buildEmptyStatePlaceholder("No items added yet") 
                  else 
                    ..._addedItems.map((item) => _buildItemTile(item)),
                  const SizedBox(height: 24),
                  _buildLabel("Tax (\$)"),
                  const SizedBox(height: 8),
                  _buildBorderedTextField(_taxController, "0.0"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ _buildLabel("Tip"), _buildTipToggle() ],
                  ),
                  const SizedBox(height: 8),
                  _buildBorderedTextField(_tipController, "15.0"),
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
                onPressed: _calculateSplit,
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

  Widget _buildSectionHeader(String title, {required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18, color: Color(0xFF00AB47)),
          label: Text("Add ${title.substring(0, title.length - 1)}", style: const TextStyle(color: Color(0xFF00AB47), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildListInput(TextEditingController controller, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00AB47))),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
       ),
      child: ListTile(
        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Assigned to: ${item['assigned']}"),
        trailing: Text("\$${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00AB47))),
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Center(child: Text(text, style: TextStyle(color: Colors.grey.shade500))),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54));

  Widget _buildBorderedTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00AB47))),
      ),
    );
  }

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