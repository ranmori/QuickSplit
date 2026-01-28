import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Ensure this points to where your themeNotifier lives

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode(); 
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  // This handles the "Edit" vs "Save" logic
  void _toggleEdit() {
    if (_isEditing) {
      _updateProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
      // Automatically pop up the keyboard
      _nameFocusNode.requestFocus();
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    try {
      await user?.updateDisplayName(_nameController.text.trim());
      await user?.reload();
      
      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // --- PROFILE HEADER ---
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 30),

          // --- NAME INPUT ---
          Text(
            "YOUR NAME", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            enabled: _isEditing, // Controlled by the button
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: BorderSide(color: Colors.transparent)
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: BorderSide(color: Theme.of(context).primaryColor)
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_circle : Icons.edit, 
                  color: Theme.of(context).primaryColor
                ),
                onPressed: _toggleEdit,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // --- DARK MODE TOGGLE ---
          _buildSettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: "Dark Mode",
            subtitle: "Switch theme appearance",
            trailing: Switch(
              value: isDark,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (bool val) {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),

          // --- ACCOUNT INFO ---
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: user?.email ?? "Not available",
          ),

          const SizedBox(height: 20),
          Text(
            "APP INFO", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint("Sign out error: $e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to sign out. Please try again.")),
                  );
                }
              }
            },          
          // --- LOGOUT BUTTON ---
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text("Sign Out"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
          ),
        ],
      ),
    );
  }

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