import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final Animation<double> opacity;
  final String text;

  const WelcomeHeader({
    super.key,
    required this.opacity,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}