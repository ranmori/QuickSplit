import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class PersonInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  const PersonInput({
    super.key,
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: controller,
              hintText: "Person Name",
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
