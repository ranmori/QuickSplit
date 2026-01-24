import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      // FIXED: In dark mode we use a slight tint to distinguish it from the scaffold background
      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
      ),
      child: ListTile(
        title: Text(
          item['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color, // FIXED
          ),
        ),
        subtitle: Text(
          "Assigned to: ${item['assigned']}",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54), // FIXED
        ),
        trailing: Text(
          "\$${item['price']}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF00AB47), // Green stays green!
          ),
        ),
      ),
    );
  }
}