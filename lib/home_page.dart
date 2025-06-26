import 'package:flutter/material.dart';
import 'driver_app/presentation/widgets/bus_widget.dart';
import 'driver_app/presentation/widgets/panels_widget.dart';
import 'driver_app/presentation/widgets/start_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isActive = false; // Indicates if the driver is active or out of service

  late AnimationController busController;
  late AnimationController panelsController;
  late AnimationController buttonFadeController;

  @override
  void initState() {
    super.initState();

    busController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    panelsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    buttonFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );

    // If active, start bus and panels animation loop
    if (isActive) {
      busController.repeat(reverse: false);
      panelsController.repeat(reverse: false);
    }
  }

  @override
  void dispose() {
    busController.dispose();
    panelsController.dispose();
    buttonFadeController.dispose();
    super.dispose();
  }

  void onStartPressed() {
    // Fade out button and start animations
    buttonFadeController.reverse().then((_) {
      setState(() {
        isActive = true;
      });
      busController.repeat(reverse: false);
      panelsController.repeat(reverse: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      body: SafeArea(
        child: Stack(
          children: [
            // Panels animation always visible
            PanelsWidget(animationController: panelsController),

            // Bus animation
            BusWidget(animationController: busController),

            // Start button and stopped bus only if inactive
            if (!isActive)
              Positioned.fill(
                child: FadeTransition(
                  opacity: buttonFadeController,
                  child: Center(
                    child: StartButton(onPressed: onStartPressed),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
