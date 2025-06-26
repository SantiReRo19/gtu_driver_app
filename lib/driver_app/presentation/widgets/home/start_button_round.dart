import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartButtonRound extends StatefulWidget {
  final VoidCallback onPressed;
  final bool active;

  const StartButtonRound({
    super.key,
    required this.onPressed,
    this.active = true,
  });

  @override
  State<StartButtonRound> createState() => _StartButtonRoundState();
}

class _StartButtonRoundState extends State<StartButtonRound>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(168, 129, 199, 132),
      end: widget.active
          ? const Color.fromARGB(185, 76, 175, 79)
          : const Color.fromARGB(170, 129, 199, 132),
    ).animate(_pulseController);
  }

  @override
  void didUpdateWidget(covariant StartButtonRound oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (_, __) {
        return ElevatedButton(
          onPressed: widget.active ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorAnimation.value,
            shape: const StadiumBorder(), // Cambiado a ovalado
            padding: const EdgeInsets.symmetric(
              horizontal: 80,
              vertical: 10,
            ), // Más ancho que alto
            elevation: 8,
          ),
          child: Text(
            'Iniciar\nTurno',
            style: GoogleFonts.comicNeue(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: widget.active ? Colors.white : Colors.black38,
              height: 1,
            ),
          ),
        );
      },
    );
  }
}
