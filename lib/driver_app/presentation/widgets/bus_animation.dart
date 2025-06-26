import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class BusAnimation extends StatelessWidget {
  final Animation<Offset> positionAnimation;
  final Animation<double> scaleAnimation;
  final DriverStatus status;

  const BusAnimation({
    super.key,
    required this.positionAnimation,
    required this.scaleAnimation,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: positionAnimation,
      builder: (_, __) {
        return FractionalTranslation(
          translation: positionAnimation.value,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: status == DriverStatus.active || status == DriverStatus.starting
                ? Image.asset(
                    'assets/bus.gif',
                    width: size.width,
                    fit: BoxFit.fitWidth,
                  )
                : Image.asset(
                    'assets/bus.png',
                    width: size.width,
                    fit: BoxFit.fitWidth,
                  ),
          ),
        );
      },
    );
  }
}