import 'package:flutter/material.dart';

class BusWidget extends StatelessWidget {
  final AnimationController animationController;

  const BusWidget({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    return SlideTransition(
      position: animation,
      child: Center(
        child: Image.asset(
          'assets/bus.png', // Replace with your bus image path
          width: 200,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
