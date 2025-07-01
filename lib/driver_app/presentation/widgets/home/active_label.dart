import 'package:flutter/material.dart';
import '../driver_status.dart';

class ActiveLabel extends StatefulWidget {
  final DriverStatus status;
  const ActiveLabel({super.key, required this.status});

  @override
  State<ActiveLabel> createState() => _ActiveLabelState();
}

class _ActiveLabelState extends State<ActiveLabel> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant ActiveLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == DriverStatus.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (widget.status) {
      case DriverStatus.active:
        text = 'Activo';
        color = Colors.green.shade400;
        break;
      case DriverStatus.starting:
        text = 'Iniciando...';
        color = Colors.orange.shade400;
        break;
      default:
        text = 'Inactivo';
        color = Colors.red.shade400;
    }

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: widget.status == DriverStatus.active ? _opacity.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}