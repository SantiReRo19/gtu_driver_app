import 'package:flutter/material.dart';
import 'active_label.dart';
import 'info_item.dart';

class PanelMain extends StatelessWidget {
  final DateTime currentTime;
  final VoidCallback onRetirePressed;

  const PanelMain({
    super.key,
    required this.currentTime,
    required this.onRetirePressed,
  });

  String get formattedTime {
    final h = currentTime.hour.toString().padLeft(2, '0');
    final m = currentTime.minute.toString().padLeft(2, '0');
    final s = currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const ActiveLabel(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              InfoItem(icon: Icons.map, label: 'Ruta: 45B'),
              InfoItem(icon: Icons.timer, label: 'Inicio: 7:00 AM'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetirePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
            ),
            child: const Text(
              'En ruta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}