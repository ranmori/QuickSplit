import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/split_record.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import 'package:flutter_application_1/services/group_service.dart';
import '../widgets/section_header.dart';
import '../widgets/person_input.dart';
import '../widgets/item_tile.dart';
import '../widgets/custom_text_field.dart';
import 'split_summary.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/orc_service.dart';

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

  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();
  final GroupService _groupService = GroupService();
  final List<Map<String, dynamic>> _addedItems = [];
  final TextEditingController _taxController = TextEditingController(text: "0.0");
  final TextEditingController _tipController = TextEditingController(text: "15.0");
  
  bool _isTipPercentage = true;
  final int _historyKey = 0;
  // --- OCR SCANNING LOGIC ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF8B00D0))),
      );
      
      try {
        final List<Map<String, dynamic>> items = await _ocrService.scanReceipt(File(image.path));
        if (!mounted) return;
        Navigator.pop(context);

        if (items.isNotEmpty) {
          _showScanResults(items);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No items found on receipt. Try a clearer photo.")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to scan receipt. Please try again.")),
        );
      }    }
  }
  

  void _removePerson(int index) {
    if (_peopleControllers.length > 1) {
      HapticFeedback.mediumImpact();
      setState(() {
        _peopleControllers.removeAt(index);
      });
    }
  }

  // --- THEME-AWARE DIALOG ---
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final FocusNode nameFocus = FocusNode();
    final FocusNode priceFocus = FocusNode();
    String? localSelectedPerson = "Everyone";

    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
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
                        Text('Add Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Item Name", isDark),
                    _buildDialogField(nameController, "e.g. Pizza", isDark, focusNode: nameFocus, nextFocus: priceFocus),
                    const SizedBox(height: 12),
                    _buildLabel("Price", isDark),
                    _buildDialogField(priceController, "0.00", isDark, isNumber: true, focusNode: priceFocus, onSubmitted: () => _handleAddItem(nameController, priceController, localSelectedPerson ?? "Everyone")),
                    const SizedBox(height: 16),
                    _buildLabel("Assign to", isDark),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          _buildAssignmentTile("Everyone", localSelectedPerson == "Everyone", isDark, () {
                            setDialogState(() => localSelectedPerson = "Everyone");
                          }),
                          ..._peopleControllers.map((person) {
                            bool isSelected = localSelectedPerson == person.text;
                            return _buildAssignmentTile(person.text, isSelected, isDark, () {
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

  void _handleAddItem(TextEditingController n, TextEditingController p, String assignedTo) {
    if (n.text.isNotEmpty && p.text.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _addedItems.add({'name': n.text, 'price': p.text, 'assigned': assignedTo});
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF8B00D0), Color(0xFF6A00A3)]),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.15 : 0.3,
                    child: Image.asset('assets/images/unnamed.png', fit: BoxFit.cover, color: isDark ? Colors.black : null, colorBlendMode: isDark ? BlendMode.darken : null),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Detailed Split',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN CONTENT ---
     // --- MAIN CONTENT ---
        Expanded(
  child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. QUICK ADD SECTION (Existing)
                  FutureBuilder<List<String>>(
                    key: ValueKey(_historyKey),
                    future: _groupService.getRecentPeople(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "QUICK ADD",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: snapshot.data!
                                  .map(
                                    (name) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: ActionChip(
                                        backgroundColor: isDark
                                            ? const Color(0xFF2D2D3F)
                                            : Colors.grey[100],
                                        avatar: CircleAvatar(
                                          backgroundColor: const Color(
                                            0xFF8B00D0,
                                          ),
                                          child: Text(
                                            name[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        label: Text(
                                          name,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        onPressed: () => _handleAddPerson(name),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // 2. PEOPLE SECTION (The "Add Person" button you were missing)
                  SectionHeader(
                    title: "People",
                    onAdd: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _peopleControllers.add(
                          TextEditingController(
                            text: 'Person ${_peopleControllers.length + 1}',
                          ),
                        );
                      });
                    },
                  ),
                  ..._peopleControllers.asMap().entries.map(
                    (e) => PersonInput(
                      controller: e.value,
                      onDelete: () => _removePerson(e.key),
                    ),
                  ),
                  

                  const SizedBox(height: 24),

                  // 3. ITEMS SECTION
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        SectionHeader(title: "Items",  onAdd: () {
                        HapticFeedback.lightImpact();
                        _showAddItemDialog();
                      }),
                      const Spacer(),
                    
                   
                      if (_addedItems.isNotEmpty)
                        TextButton.icon(
                          onPressed: _showClearWarning,
                          icon: const Icon(
                            Icons.delete_sweep_outlined,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Clear All",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                 const SizedBox(height: 12),
                  if (_addedItems.isEmpty)
                    _buildEmptyStatePlaceholder("No items added yet", isDark)
                  else
                    ..._addedItems.map((item) {
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() => _addedItems.remove(item));
                          HapticFeedback.mediumImpact();
                        },
                        background: _buildDismissBackground(isDark),
                        child: ItemTile(item: item),
                      );
                    }),

                  const SizedBox(height: 24),

                  // 4. TAX & TIP (Existing)
                  _buildLabel("Tax (\$)", isDark),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _taxController,
                    hintText: "0.0",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("Tip", isDark),
                      _buildTipToggle(isDark),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _tipController,
                    hintText: "15.0",
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          // --- FOOTER ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _calculateAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _addedItems.isEmpty ? (isDark ? Colors.white10 : const Color(0xFFD9DEE3)) : const Color(0xFF00AB47),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        backgroundColor: const Color(0xFF8B00D0),
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: const Text("Scan Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildDismissBackground(bool isDark) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D1A1A) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFE11D48)),
    );
  }

  Widget _buildAssignmentTile(String text, bool isSelected, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF00AB47) : (isDark ? Colors.white12 : Colors.grey.shade300)),
          color: isSelected ? const Color(0xFF00AB47).withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        ),
        child: Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.black54));

  Widget _buildDialogField(TextEditingController controller, String hint, bool isDark, {bool isNumber = false, FocusNode? focusNode, FocusNode? nextFocus, VoidCallback? onSubmitted}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey),
        prefixText: isNumber ? "\$ " : null,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF8B00D0))),
      ),
    );
  }

  Widget _buildTipToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
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
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300, style: BorderStyle.solid),
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.transparent,
      ),
      child: Center(child: Text(text, style: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade500, fontSize: 16))),
    );
  }

  void _showScanResults(List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Text("Confirm Scanned Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(items[index]['name'], style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    trailing: Text("\$${items[index]['price']}", style: const TextStyle(color: Color(0xFF00AB47), fontWeight: FontWeight.bold)),
                    leading: const Icon(Icons.check_circle, color: Color(0xFF00AB47)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _addAllScannedItems(items),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AB47), foregroundColor: Colors.white),
                  child: const Text("Add All Items to Bill"),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _handleAddPerson(String name) {
    HapticFeedback.lightImpact();
    _groupService.savePerson(name);
    setState(() {
      bool exists = _peopleControllers.any((controller) => controller.text.trim() == name);
      if (!exists) {
        _peopleControllers.add(TextEditingController(text: name));
      }
    });
  }

  void _addAllScannedItems(List<Map<String, dynamic>> items) {
    HapticFeedback.mediumImpact();
    setState(() {
      for (var item in items) {
        String cleanPrice = item['price'].toString().replaceAll(RegExp(r'[^\d.]'), '');
        _addedItems.add({
          'name': item['name'],
          'price': cleanPrice,
          'assigned': 'Everyone',
        });
      }
    });
    Navigator.pop(context);
  }

  void _calculateAndNavigate() {
    // Logic remains identical to your original provided snippet...
    double? tax = double.tryParse(_taxController.text); // Added ?? 0.0
    double tipInput = double.tryParse(_tipController.text) ?? 0.0; // Added ?? 0.0
    if (tax == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid tax amount")));
      return;
    }
    if (_addedItems.isEmpty) return;
    HapticFeedback.heavyImpact();

    double subtotal = 0;
    for (var item in _addedItems) {
      subtotal += double.tryParse(item['price'].toString()) ?? 0.0;
    }
    
    for (var controller in _peopleControllers) {
      String name = controller.text.trim().isEmpty ? 'unnamed' : controller.text.trim();
      
      if (name.isNotEmpty && !name.startsWith("Person ")) {
        _groupService.savePerson(name);
      }
    }

    
    double tip = _isTipPercentage ? (subtotal * (tipInput / 100)) : tipInput;
    double total = subtotal + tax + tip;

    Map<String, double> individualTotals = {};
    for (var controller in _peopleControllers) {
      individualTotals[controller.text] = 0.0;
    }

    for (var item in _addedItems) {
      double itemPrice = double.tryParse(item['price'].toString()) ?? 0.0;
      String assigned = item['assigned'].toString().trim();
      if (assigned == "Everyone") {
        int peopleCount = _peopleControllers.isEmpty ? 1 : _peopleControllers.length;
        double splitShare = itemPrice / peopleCount;
        individualTotals.updateAll((name, currentVal) => currentVal + splitShare);
      } else {
        individualTotals[assigned] = (individualTotals[assigned] ?? 0.0) + itemPrice ;
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
      individualTotals: individualTotals,
    );

    widget.onRecordAdded(newRecord);

    final summary = SplitSummaryData(
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      total: total,
      items: _addedItems,
      individualTotals: individualTotals,
      dateString: "${DateTime.now().day}/${DateTime.now().month}",
      people: [],
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => SplitSummaryScreen(data: summary),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }
  void _showClearWarning() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Clear all items?"),
      content: const Text("This will remove all items from the current bill."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _addedItems.clear();
            });
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          child: const Text("Clear All", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
}