import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'split_bill_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showSnackBar('Please accept the Terms and Conditions', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        _showSnackBar('Account created successfully!', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplitBillScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use' ? 'Email already in use.' 
                     : e.code == 'weak-password' ? 'Password too weak.' 
                     : 'An error occurred.';
      _showSnackBar(message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are currently in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor automatically picks the theme background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildHeader(isDark),
                const SizedBox(height: 40),
                
                _buildLabel('Full Name'),
                _buildTextField(
                  isDark: isDark,
                  controller: _nameController,
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (val) => val!.isEmpty ? 'Please enter your name' : null,
                ),

                const SizedBox(height: 20),
                _buildLabel('Email'),
                _buildTextField(
                  isDark: isDark,
                  controller: _emailController,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  validator: (val) => !val!.contains('@') ? 'Enter a valid email' : null,
                ),

                const SizedBox(height: 20),
                _buildLabel('Password'),
                _buildTextField(
                  isDark: isDark,
                  controller: _passwordController,
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: _passwordValidator,
                ),

                const SizedBox(height: 20),
                _buildLabel('Confirm Password'),
                _buildTextField(
                  isDark: isDark,
                  controller: _confirmPasswordController,
                  hint: 'Confirm your password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
                ),

                const SizedBox(height: 20),
                _buildTermsCheckbox(),

                const SizedBox(height: 32),
                _buildSignupButton(),

                const SizedBox(height: 24),
                _buildDivider(),

                const SizedBox(height: 24),
                _buildSocialRow(),

                const SizedBox(height: 32),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ) : null,
        filled: true,
        // Adapt fill color for dark mode
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B00D0), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  Widget _buildLogo() => Center(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8B00D0).withOpacity(0.1), 
        shape: BoxShape.circle
      ),
      child: const Icon(Icons.calculate_outlined, size: 60, color: Color(0xFF8B00D0)),
    ),
  );

  Widget _buildHeader(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Sign up to start splitting bills', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    ],
  );

  Widget _buildTermsCheckbox() => Row(
    children: [
      Checkbox(
        value: _acceptTerms,
        onChanged: (v) => setState(() => _acceptTerms = v ?? false),
        activeColor: const Color(0xFF8B00D0),
      ),
      const Expanded(child: Text("I agree to the Terms and Privacy Policy")),
    ],
  );

  Widget _buildSignupButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleSignup,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B00D0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account'),
    ),
  );

  Widget _buildDivider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[400])),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or sign up with')),
      Expanded(child: Divider(color: Colors.grey[400])),
    ],
  );

  Widget _buildSocialRow() => Row(
    children: [
      Expanded(child: _buildSocialButton(icon: Icons.g_mobiledata, label: 'Google')),
      const SizedBox(width: 16),
      Expanded(child: _buildSocialButton(icon: Icons.apple, label: 'Apple')),
    ],
  );

  Widget _buildLoginLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Already have an account? "),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
        child: const Text('Sign In', style: TextStyle(color: Color(0xFF8B00D0), fontWeight: FontWeight.bold)),
      ),
    ],
  );

  Widget _buildSocialButton({required IconData icon, required String label}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}