import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Color(0xFF5096C2),
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 17, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade400,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('Sí'),
        ),
      ],
    );
  }
}
