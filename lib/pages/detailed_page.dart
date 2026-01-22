import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    HapticFeedback.lightImpact(); // Added feedback
    setState(() {
      _peopleControllers.add(TextEditingController(text: 'Person ${_peopleControllers.length + 1}'));
    });
  }

  void _removePerson(int index) {
    if (_peopleControllers.length > 1) {
      HapticFeedback.mediumImpact(); // Added feedback
      setState(() {
        _peopleControllers.removeAt(index);
      });
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
    // Create FocusNodes specifically for this dialog instance
    final FocusNode nameFocus = FocusNode();
    final FocusNode priceFocus = FocusNode();
    
    String? localSelectedPerson = "Everyone";

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
                    _buildDialogField(
                      nameController, 
                      "e.g. Pizza",
                      focusNode: nameFocus,
                      nextFocus: priceFocus, // This triggers the jump
                    ),
                    const SizedBox(height: 12),
                    _buildLabel("Price"),
                    _buildDialogField(
                      priceController, 
                      "0.00", 
                      isNumber: true,
                      focusNode: priceFocus,
                      onSubmitted: () => _handleAddItem(nameController, priceController, localSelectedPerson ?? "Everyone"),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Assign to"),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          _buildAssignmentTile("Everyone", localSelectedPerson == "Everyone", () {
                            setDialogState(() => localSelectedPerson = "Everyone");
                          }),
                          ..._peopleControllers.map((person) {
                            bool isSelected = localSelectedPerson == person.text;
                            return _buildAssignmentTile(person.text, isSelected, () {
                              setDialogState(() => localSelectedPerson = person.text);
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B00D0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _handleAddItem(nameController, priceController, localSelectedPerson ?? "Everyone"),
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

  void _handleAddItem(
    TextEditingController n,
    TextEditingController p,
    String assignedTo,
  ) {
    if (n.text.isNotEmpty && p.text.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _addedItems.add({
          'name': n.text,
          'price': p.text,
          'assigned': assignedTo,
        });
      });
      Navigator.pop(context);
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Hero(
          tag: 'app_title', // The unique ID for the animation
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Detailed Split',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF8B00D0),
        flexibleSpace: Hero(
          tag: 'header_gradient', // The background animation
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B00D0), Color(0xFF6A00A3)],
              ),
            ),
          ),
        ),
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
                    ..._addedItems.map((item) {
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            _addedItems.remove(item);
                          });
                          HapticFeedback.mediumImpact();
                        },
                       background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            // A soft, subtle rose-tinted background (Modern & clean)
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Modern "Remove" Icon: Thinner lines, rounded ends
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE11D48,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Remove",
                                style: TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: ItemTile(item: item),
                      );
                    }),
                  const SizedBox(height: 24),
                  _buildLabel("Tax (\$)"),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _taxController, hintText: "0.0", keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("Tip"),
                      _buildTipToggle(),
                    ],
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
                onPressed: _calculateAndNavigate,
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

  // Logic functions remain the same as your previous version
  void _calculateAndNavigate() {
    double ? tax = double.tryParse(_taxController.text);
    if(tax== null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid tax amount"))
      );
      return;
    }
    if (_addedItems.isEmpty) return;
    HapticFeedback.heavyImpact();

    double subtotal = 0;
    for (var item in _addedItems) {
      subtotal += double.tryParse(item['price'].toString()) ?? 0.0;
    }

   
    double tipInput = double.tryParse(_tipController.text) ?? 0.0;
    double tip = _isTipPercentage ? (subtotal * (tipInput / 100)) : tipInput;
    double total = subtotal + tax + tip;

    Map<String, double> individualTotals = {};
    for (var controller in _peopleControllers) {
      individualTotals[controller.text] = 0.0;
    }

    for (var item in _addedItems) {
      double itemPrice = double.tryParse(item['price'].toString()) ?? 0.0;
      String assigned = item['assigned'];

      if (assigned == "Everyone") {
        double splitShare = itemPrice / _peopleControllers.length;
        individualTotals.updateAll((name, currentVal) => currentVal + splitShare);
      } else {
        individualTotals[assigned] = (individualTotals[assigned] ?? 0.0) + itemPrice;
      }
    }

    if (subtotal > 0) {
      double extraCharges = tax + tip;
      individualTotals.updateAll((name, personalSubtotal) {
        double proportion = personalSubtotal / subtotal;
        return personalSubtotal + (extraCharges * proportion);
      });
    }

    final newRecord = SplitRecord(
      id: DateTime.now().toString(),
      title: _addedItems.isNotEmpty ? _addedItems.first['name'] : 'Split',
      totalAmount: '\$${total.toStringAsFixed(2)}',
      dateTime: DateTime.now().toIso8601String(),
      items: List<Map<String, dynamic>>.from(_addedItems),
      peopleCount: _peopleControllers.length, 
      perPersonAmount: '\$${(total / _peopleControllers.length).toStringAsFixed(2)}',
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      individualTotals: individualTotals
    );

    widget.onRecordAdded(newRecord);

    final summary = SplitSummaryData(
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      total: total,
      items: _addedItems,
      individualTotals: individualTotals,
      dateString: "${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}",
      people: [],
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 600,
        ), // Slightly slower to see the magic
        pageBuilder: (context, animation, secondaryAnimation) =>
            SplitSummaryScreen(data: summary),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
);
  }

  // --- HELPERS ---

  Widget _buildAssignmentTile(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF00AB47) : Colors.grey.shade300),
          color: isSelected ? const Color(0xFF00AB47).withOpacity(0.05) : Colors.white,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54));

  Widget _buildDialogField(
    TextEditingController controller, 
    String hint, {
    bool isNumber = false,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: !isNumber, 
      keyboardType: isNumber 
          ? const TextInputType.numberWithOptions(decimal: true) 
          : TextInputType.text,
      textInputAction: isNumber ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else if (onSubmitted != null) {
          onSubmitted();
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixText: isNumber ? "\$ " : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Color(0xFF8B00D0)),
        ),
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
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isTipPercentage = label == "%");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isActive ? const Color(0xFF00AB47) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
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
        child: Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ),
    );
  }
}