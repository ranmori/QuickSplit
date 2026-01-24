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
    widget.onDelete(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Record deleted"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E2E) 
            : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return "Just now";
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(parsedDate);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // --- ADAPTIVE HEADER ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B00D0), Color(0xFF6A00A3)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.15 : 0.3,
                    child: Image.asset(
                      'assets/images/unnamed.png',
                      fit: BoxFit.cover,
                      color: isDark ? Colors.black : null,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN LIST ---
          Expanded(
            child: widget.history.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.history.length,
                    itemBuilder: (context, index) {
                      final item = widget.history[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => _handleDelete(item.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24.0),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF5350).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: HistoryCard(
                            title: item.title,
                            amount: item.totalAmount,
                            timeAgo: _formatDateTime(item.dateTime),
                            people: '${item.peopleCount} people',
                            perPerson: item.perPersonAmount,
                            onTap: () {
                              final List<Map<String, dynamic>> safeItems = item.items
                                  .map((i) => {
                                        'name': i['name']?.toString() ?? "Item",
                                        'price': i['price']?.toString() ?? "0.00",
                                        'assigned': i['assigned']?.toString() ?? "Everyone",
                                      })
                                  .toList();

                              final summaryData = SplitSummaryData(
                                total: double.tryParse(item.totalAmount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
                                subtotal: item.subtotal,
                                tax: item.tax,
                                tip: item.tip,
                                items: safeItems,
                                people: [],
                                dateString: _formatDateTime(item.dateTime),
                                individualTotals: item.individualTotals ??
                                    {
                                      "Per Person": double.tryParse(item.perPersonAmount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Icon(
                Icons.receipt_long_outlined, 
                size: 64, 
                color: isDark ? Colors.purple[200]?.withOpacity(0.5) : Colors.grey.shade400
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Records Found",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your split history will appear here once you finish a calculation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white38 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B00D0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Start Splitting", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}