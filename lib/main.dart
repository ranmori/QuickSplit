import 'package:flutter/material.dart';
import 'pages/quick_split.dart';
import 'pages/detailed_page.dart';
import 'pages/history.dart';
import 'models/split_record.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B00D0),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplitBillScreen(),
    );
  }
}

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final List<SplitRecord> _historyList = [
    SplitRecord(
      id: '0',
      title: 'Detailed Split',
      totalAmount: '\$39.10',
      dateTime: '31m ago',
      peopleCount: 2,
      perPersonAmount: '\$19.55',
      items: [
        {'name': 'Pizza', 'price': '30.00', 'assigned': 'Alex, Sam'},
        {'name': 'Drinks', 'price': '9.10', 'assigned': 'Sam'},
      ],
      subtotal: 30.00,
      tax: 2.10,
      tip: 7.00,
    ),
  ];

  void _deleteRecord(String id) {
    setState(() {
      _historyList.removeWhere((record) => record.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. MODERN PURPLE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF8B00D0),
              
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QuickSplit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Split the bill in under 30 seconds',
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // 2. MENU CARDS (Styled to match your "Design" image)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildMenuCard(
                 icon: Icons.calculate_outlined,
                  iconColor: const Color(0xFF8B00D0),
                  iconBg: const Color(0xFFF3E5F5), // Soft purple bg
                  title: 'Quick Split',
                  subtitle: 'Divide total equally among everyone',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuickSplitPage(
                          onRecordAdded: (newRecord) {
                            setState(() => _historyList.insert(0, newRecord));
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  icon: Icons.receipt_long_outlined, // Modern outlined icon
                  iconColor: const Color(0xFF10B981), // Emerald Green
                  iconBg: const Color(0xFFECFDF5), // Soft emerald bg
                  title: 'Detailed Split',
                  subtitle: 'Assign specific items to each person',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedSplitPage(
                          onRecordAdded: (newRecord) {
                            setState(() => _historyList.insert(0, newRecord));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // 3. VIEW HISTORY BUTTON
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  foregroundColor: const Color(0xFF475569),
                  elevation: 0,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                        history: _historyList, 
                        onDelete: _deleteRecord,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded, size: 20),
                label: Text('View History (${_historyList.length})', 
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // THE "DESIGNED" ICON CONTAINER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16), // The Squircle
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}