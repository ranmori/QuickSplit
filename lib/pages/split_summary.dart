import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import 'package:flutter_application_1/widgets/rolling_number.dart';
import 'package:share_plus/share_plus.dart';

class SplitSummaryScreen extends StatelessWidget {
  final SplitSummaryData data;

  const SplitSummaryScreen({super.key, required this.data});

  void _shareSummary() {
    StringBuffer summaryBuffer = StringBuffer();
    summaryBuffer.writeln('Split Summary');
    summaryBuffer.writeln('Date: ${data.dateString}');
    summaryBuffer.writeln('Total: \$${data.total.toStringAsFixed(2)}');
    summaryBuffer.writeln('\nPer Person:');
    data.individualTotals.forEach((name, amount) {
      summaryBuffer.writeln('- $name: \$${amount.toStringAsFixed(2)}');
    });
    summaryBuffer.writeln('\nItems:');
    for (var item in data.items) {
      // ✅ FIX: Added null checks for sharing
      String itemName = item['name']?.toString() ?? 'Item';
      String itemPrice = item['price']?.toString() ?? '0.00';
      String assigned = item['assigned']?.toString() ?? 'Everyone';
      summaryBuffer.writeln('- $itemName: \$$itemPrice (Assigned to: $assigned)');
    }

    Share.share(summaryBuffer.toString(), subject: 'Split Summary');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // --- TECH HEADER ---
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
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Split Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data.dateString,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGrandTotalCard(isDark),

                  const SizedBox(height: 32),

                  // Per Person Section
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 20, color: Color(0xFF8B00D0)),
                      const SizedBox(width: 8),
                      Text(
                        'Individual Totals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...data.individualTotals.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPersonCard(entry.key, entry.value, isDark),
                      )),

                  const SizedBox(height: 32),

                  // Items Section
                  Row(
                    children: [
                      const Icon(Icons.list_alt_rounded, size: 20, color: Color(0xFF8B00D0)),
                      const SizedBox(width: 8),
                      Text(
                        'Item Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...data.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildItemCard(
                          // ✅ FIX: Added null safety here
                          item['name']?.toString() ?? 'Item',
                          item['price']?.toString() ?? '0.00',
                          item['assigned']?.toString() ?? 'Everyone',
                          isDark,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // --- BOTTOM SHARE ACTION ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _shareSummary,
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Share Full Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B00D0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildGrandTotalCard(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B00D0).withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GRAND TOTAL',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          RollingAmount(
            value: data.total,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDetailRow('Subtotal', '\$${data.subtotal.toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _buildDetailRow('Tax', '\$${data.tax.toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _buildDetailRow('Tip', '\$${data.tip.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(String name, double amount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF8B00D0).withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF8B00D0), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8B00D0),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.share_rounded, 
              color: isDark ? Colors.white38 : Colors.grey, 
              size: 20
            ),
            onPressed: () {
              Share.share('$name owes \$${amount.toStringAsFixed(2)}',
                  subject: 'Your Split Amount');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String name, String price, String assignedTo, bool isDark) {
    double itemPrice = double.tryParse(price) ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B))),
              Text(
                '\$${itemPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.assignment_ind_outlined, 
                size: 14, 
                color: isDark ? Colors.white38 : Colors.grey
              ),
              const SizedBox(width: 4),
              Text(
                assignedTo,
                style: TextStyle(
                  fontSize: 13, 
                  color: isDark ? Colors.white38 : Colors.grey
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}