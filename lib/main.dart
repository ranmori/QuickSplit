import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      title: 'QuickSplit Tech',
      // --- LIGHT THEME ---
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF8B00D0),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade200,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B00D0),
          foregroundColor: Colors.white,
        ),
      ),
      // --- DARK THEME ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8B00D0),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A), // Deep Midnight
        cardColor: const Color(0xFF1E1E2E), // Lighter card depth
        dividerColor: Colors.white10,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B00D0),
          secondary: Color(0xFF00AB47),
          surface: Color(0xFF1E1E2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system, // Auto-switches based on phone settings
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
      individualTotals: {'Alex': 15.00, 'Sam': 24.10},
    ),
  ];

  void _deleteRecord(String id) {
    setState(() {
      _historyList.removeWhere((record) => record.id == id);
    });
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B00D0), Color(0xFF6A00A3)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.15 : 0.35, // Dimmer in Dark Mode
                    child: Image.asset(
                      'assets/images/unnamed.png',
                      fit: BoxFit.cover,
                      color: isDark ? Colors.black : null,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
                  child: Column(
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
                ),
              ],
            ),
          ),

          // --- MENU CARDS SECTION ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.calculate_outlined,
                  iconColor: const Color(0xFF8B00D0),
                  iconBg: isDark ? const Color(0xFF2D1B4D) : const Color(0xFFF3E5F5),
                  title: 'Quick Split',
                  subtitle: 'Divide total equally among everyone',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuickSplitPage(
                          onRecordAdded: (newRecord) => setState(() => _historyList.insert(0, newRecord)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  context,
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF10B981),
                  iconBg: isDark ? const Color(0xFF063321) : const Color(0xFFECFDF5),
                  title: 'Detailed Split',
                  subtitle: 'Assign specific items to each person',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedSplitPage(
                          onRecordAdded: (newRecord) => setState(() => _historyList.insert(0, newRecord)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- ADAPTIVE FOOTER ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC),
                  foregroundColor: isDark ? Colors.white70 : const Color(0xFF475569),
                  elevation: 0,
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                label: Text(
                  'View History (${_historyList.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white54 
                              : Colors.grey.shade500,
                        ),
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