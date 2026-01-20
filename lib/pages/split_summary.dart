import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/summary_data.dart';
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
      summaryBuffer.writeln('- ${item['name']}: \$${item['price']} (Assigned to: ${item['assigned']})');
    }

    Share.share(summaryBuffer.toString(), subject: 'Split Summary');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER SECTION ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B00D0), Color(0xFF4A00B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Split Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.dateString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grand Total Card
                    _buildGrandTotalCard(),

                    const SizedBox(height: 24),

                    // Per Person Section
                    const Text(
                      'Per Person',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...data.individualTotals.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPersonCard(entry.key, entry.value),
                        )),

                    const SizedBox(height: 24),

                    // Items Section
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...data.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildItemCard(
                            item['name'],
                            item['price'].toString(),
                            item['assigned'],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM SHARE BUTTON ---
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _shareSummary();
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'Share Split',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B00D0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildGrandTotalCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grand Total',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${data.total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          _buildDetailRow('Subtotal', '\$${data.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildDetailRow('Tax', '\$${data.tax.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildDetailRow('Tip', '\$${data.tip.toStringAsFixed(2)}'),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(String name, double amount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.grey, size: 20),
            onPressed: () {
              Share.share('$name owes \$${amount.toStringAsFixed(2)}', subject: 'Your Split Amount');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String name, String price, String assignedTo) {
    double itemPrice = double.tryParse(price) ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              Text(
                '\$${itemPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              assignedTo,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}