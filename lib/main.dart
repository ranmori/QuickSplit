import 'package:flutter/material.dart';

// haptic feedback
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart'; // Import this
import 'firebase_options.dart'; //

import 'pages/onboarding_page.dart';
import 'pages/quick_split.dart';
import 'pages/detailed_page.dart';
import 'pages/history.dart';
import 'models/split_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(37, 83, 139, 1),
          foregroundColor: Colors.white,
        ),
      ),
      // Start with onboarding page
      home: const OnboardingPage(),
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
      dateTime: DateTime.now().subtract(const Duration(minutes: 31)).toIso8601String(),
      peopleCount: 2,
      perPersonAmount: '\$19.55',
      items: [
        {'name': 'Pizza', 'price': '30.00', 'assigned': 'Alex, Sam'},
        {'name': 'Drinks', 'price': '9.10', 'assigned': 'Sam'},
      ],
      subtotal: 30.00,
      tax: 2.10,
      tip: 7.00,
      individualTotals: {
        'Alex': 15.00,
        'Sam': 24.10,
      },
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
                Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
  decoration: const BoxDecoration(
    // Use a Gradient instead of a solid color
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8B00D0), // Your original Purple
        Color(0xFF6A00A3), // A slightly deeper purple
      ],
    ),
  ),
  child: Stack( // We use a Stack to add a background "glow"
    children: [
      // OPTIONAL: Subtle Background "Orb" for that Design look
      Positioned(
        right: -50,
        top: -50,
        child: Container(
          width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .1),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'QuickSplit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Split the bill in under 30 seconds',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                 _buildMenuCard(
                 icon: Icons.calculate_outlined,
                  iconColor: const Color(0xFF8B00D0),
                  iconBg: const Color(0xFFF3E5F5),
                  title: 'Quick Split',
                  subtitle: 'Divide total equally among everyone',
                  onTap: () {
                     HapticFeedback.lightImpact();

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
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
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
                  side: BorderSide(color: Colors.grey.shade200,width: 1),
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
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        
         BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
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