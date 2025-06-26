// panels_widget.dart
import 'package:flutter/material.dart';

class PanelsWidget extends StatelessWidget {
  const PanelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 4 paneles en fila o columna, con algo de espacio y estilo
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF5FBF7A), // verde claro
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _panelItem(icon: Icons.access_time, label: 'Hora', onTap: () {}),
          _panelItem(icon: Icons.map, label: 'Ruta', onTap: () {}),
          _panelItemActive(),
          _panelItem(icon: Icons.info_outline, label: 'Estado', onTap: () {}),
        ],
      ),
    );
  }

  Widget _panelItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _panelItemActive() {
    // Botón titilante para estado activo tipo "bombillita"
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.5),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lightbulb, size: 36, color: Colors.yellowAccent),
              SizedBox(height: 8),
              Text('Activo', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
      onEnd: () {
        // Para loop infinito del titileo
        // No es necesario si usas repeat en AnimationController
      },
    );
  }
}
