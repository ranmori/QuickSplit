import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // We remove spaceBetween so they sit next to each other
    return Row(
      mainAxisSize: MainAxisSize.min, // Takes only as much space as needed
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        // --- THIS IS THE GAP YOU NEED ---
        const SizedBox(width: 12), 
        
        TextButton.icon(
          onPressed: onAdd,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.add, size: 18, color: Color(0xFF00AB47)),
          label: Text(
            "Add ${title.endsWith('s') ? title.substring(0, title.length - 1) : title}",
            style: const TextStyle(
              color: Color(0xFF00AB47),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}