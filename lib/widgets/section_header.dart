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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18, color: Color(0xFF00AB47)),
          label: Text(
            "Add ${title.substring(0, title.length)}",
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
