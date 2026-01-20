import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import 'package:flutter_application_1/pages/split_summary.dart';
import '../widgets/history_card.dart';
import '../models/split_record.dart';

class HistoryScreen extends StatefulWidget {
  final List<SplitRecord> history;
  final void Function(String id) onDelete;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onDelete,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _handleDelete(String id) {
    setState(() {
      widget.onDelete(id); 
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Record deleted"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return "Just now";
    
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(parsedDate);

      if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else if (diff.inDays < 7) {
        return "${diff.inDays}d ago";
      } else {
        return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
      }
    } catch (e) {
      return dateTime; // Return as-is if not ISO format
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: widget.history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.history.length,
              itemBuilder: (context, index) {
                final item = widget.history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: HistoryCard(
                    title: item.title,
                    amount: item.totalAmount,
                    timeAgo: _formatDateTime(item.dateTime),
                    people: '${item.peopleCount} people',
                    perPerson: item.perPersonAmount,
                    onTap: () {
                      final List<Map<String, dynamic>> safeItems = item.items
                          .map((i) {
                            return {
                              'name': i['name']?.toString() ?? "Item",
                              'price': i['price']?.toString() ?? "0.00",
                              'assigned': i['assigned']?.toString() ?? "Everyone",
                            };
                          })
                          .toList();

                      final summaryData = SplitSummaryData(
                        total: double.tryParse(
                              item.totalAmount.replaceAll(RegExp(r'[^\d.]'), ''),
                            ) ?? 0.0,
                        subtotal: item.subtotal,
                        tax: item.tax,
                        tip: item.tip,
                        items: safeItems,
                        people: [],
                        dateString: _formatDateTime(item.dateTime),
                        individualTotals: item.individualTotals ?? 
                            {
                              "Per Person": double.tryParse(
                                item.perPersonAmount.replaceAll(RegExp(r'[^\d.]'), ''),
                              ) ?? 0.0,
                            },
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplitSummaryScreen(data: summaryData),
                        ),
                      );
                    },
                    onDelete: () => _handleDelete(item.id),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No history yet", style: TextStyle(color: Colors.grey)),
    );
  }
}