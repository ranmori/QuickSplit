import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../models/onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: Icons.calculate_outlined,
      title: 'Split Bills Easily',
      description: 'Divide expenses among friends quickly and fairly with just a few taps',
      color: const Color(0xFF8B00D0),
    ),
    OnboardingData(
      image: Icons.receipt_long_outlined,
      title: 'Track Every Detail',
      description: 'Assign specific items to people and keep detailed records of all splits',
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      image: Icons.history_rounded,
      title: 'View History',
      description: 'Access all your past splits anytime and share summaries with friends',
      color: const Color(0xFF3B82F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], textColor, subTextColor, isDark);
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage, isDark),
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  if (_currentPage == _pages.length - 1) ...[
                    // Get Started Button
                    _buildPrimaryButton('Get Started', () => _navigateToSignup()),
                    const SizedBox(height: 16),
                    // Login Button (Outlined)
                    _buildSecondaryButton('I Already Have an Account', () => _navigateToLogin(), isDark),
                  ] else ...[
                    // Next Button
                    _buildPrimaryButton('Next', () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, Color titleColor, Color descColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: data.color.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.image,
              size: 100,
              color: data.color,
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: descColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B00D0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : const Color(0xFF8B00D0),
          side: BorderSide(
            color: isDark ? Colors.white24 : const Color(0xFF8B00D0),
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF8B00D0) 
            : (isDark ? Colors.white10 : Colors.grey[300]),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Navigation methods stay the same
  void _navigateToSignup() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupPage()));
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}