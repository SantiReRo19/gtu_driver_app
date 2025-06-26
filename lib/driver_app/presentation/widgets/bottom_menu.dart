import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onRoutesPressed;
  final VoidCallback onOtherPressed;

  const BottomMenu({
    super.key,
    required this.onProfilePressed,
    required this.onRoutesPressed,
    required this.onOtherPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onRoutesPressed,
            icon: const Icon(Icons.route, size: 32, color: Colors.black54),
          ),
          IconButton(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person, size: 36, color: Colors.black87),
          ),
          IconButton(
            onPressed: onOtherPressed,
            icon: const Icon(Icons.menu, size: 32, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}