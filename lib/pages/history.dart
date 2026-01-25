import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import 'package:flutter_application_1/pages/split_summary.dart';
import '../widgets/history_card.dart';
import '../models/split_record.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // --- HELPER: Handles Cloud Deletion ---
  void _deleteFromCloud(BuildContext context, String docId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Record deleted permanently"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // --- HELPER: Logic for Time Formatting ---
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // --- ADAPTIVE HEADER (Stays the same) ---
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
                    child: Image.asset('assets/images/unnamed.png', fit: BoxFit.cover),
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
                        const Text('History', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN LIST (Now uses StreamBuilder) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('history')
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading history"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B00D0)));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    // Convert Firestore data back into your SplitRecord model
                    final item = SplitRecord.fromMap(data, docs[index].id);

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteFromCloud(context, item.id),
                      background: _buildDismissibleBackground(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: HistoryCard(
                          title: item.title,
                          amount: item.totalAmount,
                          timeAgo: _formatDateTime(item.dateTime),
                          people: '${item.peopleCount} people',
                          perPerson: item.perPersonAmount,
                          onTap: () {
                            // Mapping data to the summary screen
                            final summaryData = SplitSummaryData(
                              total: double.tryParse(item.totalAmount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
                              subtotal: item.subtotal,
                              tax: item.tax,
                              tip: item.tip,
                              items: item.items,
                              people: [], 
                              dateString: _formatDateTime(item.dateTime),
                              individualTotals: item.individualTotals ?? {"Per Person": 0.0},
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SplitSummaryScreen(data: summaryData)),
                            );
                          },
                          onDelete: () => _deleteFromCloud(context, item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24.0),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... (The rest of your existing empty state code)
            Icon(Icons.receipt_long_outlined, size: 64, color: isDark ? Colors.purple[200] : Colors.grey),
            const SizedBox(height: 24),
            const Text("No Records Found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B00D0)),
              child: const Text("Start Splitting"),
            )
          ],
        ),
      ),
    );
  }
}