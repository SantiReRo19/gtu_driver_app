import 'package:flutter/material.dart';
import 'start_button_round.dart';
import 'bus_animation.dart';
import '../driver_status.dart';

class StartSection extends StatelessWidget {
  final DriverStatus status;
  final Animation<Offset> busPositionAnimation;
  final Animation<double> busScaleAnimation;
  final VoidCallback onStartPressed;
  final bool buttonActive;

  const StartSection({
    super.key,
    required this.status,
    required this.busPositionAnimation,
    required this.busScaleAnimation,
    required this.onStartPressed,
    required this.buttonActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Bus
        Align(
          alignment: const Alignment(0, -0.1),
          child: status == DriverStatus.active || status == DriverStatus.starting
              ? BusAnimation(
                  positionAnimation: busPositionAnimation,
                  scaleAnimation: busScaleAnimation,
                  status: status,
                )
              : Image.asset(
                  'assets/bus.png',
                  width: size.width,
                  fit: BoxFit.fitWidth,
                ),
        ),
        // Botón de inicio
        if (status == DriverStatus.inactive || status == DriverStatus.offDuty)
          Positioned(
            top: size.height * 0.65,
            left: 0,
            right: 0,
            child: Center(
              child: StartButtonRound(
                onPressed: onStartPressed,
                active: buttonActive,
              ),
            ),
          ),
      ],
    );
  }
}