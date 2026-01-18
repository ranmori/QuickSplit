import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/summary_data.dart';
import 'split_summary.dart';
import '../widgets/history_card.dart';
import '../main.dart';
import '../models/split_record.dart';


class HistoryScreen extends StatelessWidget {
  final List<SplitRecord> history;
  const HistoryScreen({super.key, required this.history});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.pop(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplitBillScreen(),
                ),
              );
          },
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
      body: history.isEmpty
          ? const Center(child: Text("No history yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: HistoryCard(
                    title: item.title,
                    amount: item.totalAmount,
                    timeAgo: item.dateTime,
                    people: '${item.peopleCount} people',
                    perPerson: item.perPersonAmount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  SplitSummaryScreen(
                          data: SplitSummaryData(
                            subtotal: 0.0,
                            tax: 0.0,
                            tip: 0.0,
                            total: 0.0,
                            items: [],
                            people: [],
                            dateString: "",
                            individualTotals: {},
                          ),
                        )),
                      );
                    },
                    onDelete: () {},
                  ),
                );
              },
            ),
    );

}
}