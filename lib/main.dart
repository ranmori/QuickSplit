import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'pages/onboarding_page.dart';
import 'pages/quick_split.dart';
import 'pages/detailed_page.dart';
import 'pages/history.dart';
import 'pages/settings_page.dart'; // Ensure this exists
import 'models/split_record.dart';

// --- THEME MANAGER ---
// This allows the theme to change across the entire app instantly
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickSplit Tech',
          themeMode: currentMode,
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
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF8B00D0),
            scaffoldBackgroundColor: const Color(0xFF0F0F1A),
            cardColor: const Color(0xFF1E1E2E),
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
              elevation: 0,
            ),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const SplitBillScreen();
              }
              return const OnboardingPage();
            },
          ),
        );
      },
    );
  }
}

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final List<SplitRecord> _historyList = [];

  Future<void> _saveRecordToFirestore(SplitRecord record) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .add(record.toMap());
      } catch (e) {
        debugPrint("Error saving: $e");
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out?"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Stay", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Log Out",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    // --- DISPLAY NAME LOGIC ---
    // Safely finds a name to show, or defaults to "User"
    final String displayName = user?.displayName ?? 
                               user?.email?.split('@')[0] ?? 
                               "User";

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
                    opacity: isDark ? 0.15 : 0.35,
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
                    children: [
                      Text(
                        'Hi, $displayName!',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        'QuickSplit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Split bills in seconds, not minutes.',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- MENU CARDS ---
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
                          onRecordAdded: (newRecord) {
                            setState(() => _historyList.insert(0, newRecord));
                            _saveRecordToFirestore(newRecord);
                          },
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
                          onRecordAdded: (newRecord) {
                            setState(() => _historyList.insert(0, newRecord));
                            _saveRecordToFirestore(newRecord);
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

          // --- BOTTOM ACTION BAR (Icons moved here for UX) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Row(
              children: [
                // History Button
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC),
                        foregroundColor: isDark ? Colors.white70 : const Color(0xFF475569),
                        elevation: 0,
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
                      icon: const Icon(Icons.history_rounded, size: 22),
                      label: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('history')
                            .snapshots(),
                        builder: (context, snapshot) {
                          int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return Text('History ($count)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Profile/Settings
                _buildBottomIconButton(
                  context,
                  icon: Icons.person_outline,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                    // Refresh home screen after returning from settings (updates name/theme)
                    setState(() {});
                  },
                ),
                const SizedBox(width: 12),
                // Logout
                _buildBottomIconButton(
                  context,
                  icon: Icons.logout_rounded,
                  color: Colors.redAccent.withOpacity(0.8),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- HELPER UI BUILDERS ---

  Widget _buildBottomIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed, Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? (isDark ? Colors.white70 : const Color(0xFF475569)), size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(18)),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey.shade500)),
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