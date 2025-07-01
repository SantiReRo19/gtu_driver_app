import 'package:flutter/material.dart';
import 'active_label.dart';
import 'info_item.dart';
import '../driver_status.dart';

class PanelMain extends StatelessWidget {
  final DateTime currentTime;
  final DriverStatus status;
  final VoidCallback onRetirePressed;
  final VoidCallback onStartPressed;

  final String? rutaAsignada;
  final String? horaInicioTurnoStr;

  const PanelMain({
    super.key,
    required this.currentTime,
    required this.status,
    required this.onRetirePressed,
    required this.onStartPressed,
    required this.rutaAsignada,
    required this.horaInicioTurnoStr,
  });

  String get formattedTime {
    int hour = currentTime.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final m = currentTime.minute.toString().padLeft(2, '0');
    final s = currentTime.second.toString().padLeft(2, '0');
    return '$hour:$m:$s $ampm';
  }

  String get formattedDate {
    // Ejemplo: 30/06/2025
    return '${currentTime.day.toString().padLeft(2, '0')}/'
        '${currentTime.month.toString().padLeft(2, '0')}/'
        '${currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = status == DriverStatus.active;
    final isInactive =
        status == DriverStatus.inactive || status == DriverStatus.offDuty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isInactive
            ? const Color(0xFFE3F2FD) // Azul claro
            : const Color(0xFFE9F7EF), // Verde claro para activo
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
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ActiveLabel(status: status),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoItem(
                icon: Icons.map,
                label: 'Ruta: ${rutaAsignada ?? "Sin ruta"}',
              ),
              InfoItem(
                icon: Icons.timer,
                label: 'Inicio: ${horaInicioTurnoStr ?? "--:--"}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isActive)
            ElevatedButton(
              onPressed: onRetirePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(132, 80, 150, 194),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              child: const Text(
                'Finalizar turno',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          if (isInactive) _BlinkingButton(onPressed: onStartPressed),
        ],
      ),
    );
  }
}

class _BlinkingButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _BlinkingButton({required this.onPressed});

  @override
  State<_BlinkingButton> createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<_BlinkingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
            ),
            child: const Text(
              'Iniciar turno',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
