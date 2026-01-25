import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Important: Import your main.dart to access the global themeNotifier
import '../main.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current name or empty string if null
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _updateProfile() async {
    // Prevent empty names
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    try {
      // 1. Update the profile on Firebase
      await user?.updateDisplayName(_nameController.text.trim());
      
      // 2. IMPORTANT: Force a reload to sync local user object
      await user?.reload();
      
      setState(() => _isEditing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are currently in dark mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // --- PROFILE ICON ---
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 30),

          // --- NAME SECTION ---
          Text(
            "YOUR NAME", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            enabled: _isEditing,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter your name",
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: BorderSide.none
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_circle : Icons.edit, 
                  color: Theme.of(context).primaryColor
                ),
                onPressed: () {
                  if (_isEditing) {
                    _updateProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // --- THEME TOGGLE ---
          _buildSettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: "Dark Mode",
            subtitle: "Switch between light and dark themes",
            trailing: Switch(
              value: isDark,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool val) {
                // This updates the ValueNotifier in main.dart
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),

          // --- EMAIL SECTION ---
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: user?.email ?? "Not available",
            onTap: () {
              // Usually read-only for Firebase Auth unless re-authenticating
            },
          ),

          const SizedBox(height: 20),
          Text(
            "APP INFO", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "Version",
            subtitle: "1.0.2 Build 42",
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          // Delete Account Button (Optional but good UX)
          TextButton(
            onPressed: () {
              // Logic for account deletion could go here
            },
            child: const Text(
              "Delete Account", 
              style: TextStyle(color: Colors.redAccent)
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for list items
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}