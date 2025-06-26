import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/start_button_round.dart';
import '../widgets/panel_main.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/bus_animation.dart';
import '../widgets/confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum DriverStatus { inactive, starting, active, offDuty }

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DriverStatus status = DriverStatus.inactive;

  late AnimationController busMoveScaleController;
  late Animation<Offset> busPositionAnimation;
  late Animation<double> busScaleAnimation;

  late AnimationController buttonFadeController;
  late Animation<double> buttonFadeAnimation;

  late AnimationController headerOpacityController;
  late Animation<double> headerOpacityAnimation;

  late AnimationController elementsOpacityController;
  late Animation<double> elementsOpacityAnimation;

  late Timer? timer;
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Actualizar hora cada segundo
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
      });
    });

    busMoveScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    busPositionAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.7),
        ).animate(
          CurvedAnimation(
            parent: busMoveScaleController,
            curve: Curves.easeInOut,
          ),
        );

    busScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: busMoveScaleController, curve: Curves.easeInOut),
    );

    buttonFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );

    buttonFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: buttonFadeController, curve: Curves.easeOut),
    );

    headerOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      value: 1.0, // Empieza visible
    );
    headerOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: headerOpacityController, curve: Curves.easeOut),
    );

    elementsOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    elementsOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: elementsOpacityController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    busMoveScaleController.dispose();
    buttonFadeController.dispose();
    headerOpacityController.dispose();
    elementsOpacityController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void onStartPressed() {
    if (status != DriverStatus.inactive) return;

    setState(() {
      status = DriverStatus.starting;
    });

    buttonFadeController.forward().then((_) async {
      await busMoveScaleController.forward();
      setState(() {
        status = DriverStatus.active;
      });
      headerOpacityController.forward();
      elementsOpacityController.forward();
    });
  }

  void onRetirePressed() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Confirmación',
        content: '¿Seguro que quieres retirarte del turno?',
        onConfirm: _retireTurn,
      ),
    );
  }

  void _retireTurn() async {
    if (status != DriverStatus.active) return;

    await busMoveScaleController.reverse();

    setState(() {
      status = DriverStatus.offDuty;
    });
    buttonFadeController.reverse();
    headerOpacityController.reset();
    elementsOpacityController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Texto arriba "Listo para comenzar"
            if (status == DriverStatus.inactive ||
                status == DriverStatus.offDuty)
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: headerOpacityController,
                  child: const Center(
                    child: Text(
                      '¿Estas listo?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        height: 1.2, // Reduce el espacio entre líneas
                      ),
                    ),
                  ),
                ),
              ),

            // Bus (imagen o gif) con animación
            Align(
              alignment: const Alignment(0, -0.1), // Más arriba del centro
              child: BusAnimation(
                positionAnimation: busPositionAnimation,
                scaleAnimation: busScaleAnimation,
                status: status,
              ),
            ),

            // Botón iniciar (grande, verde claro, con check al presionar)
            if (status == DriverStatus.inactive ||
                status == DriverStatus.offDuty)
              Positioned(
                top: size.height * 0.65,
                left: 0,
                right: 0,
                child: Center(
                  child: StartButtonRound(
                    onPressed: onStartPressed,
                    active: status == DriverStatus.offDuty ? false : true,
                  ),
                ),
              ),

            // Panel principal debajo del bus (hora, estado, ruta y botón "En ruta")
            if (status == DriverStatus.active ||
                status == DriverStatus.starting)
              Positioned(
                top: size.height * 0.4,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: elementsOpacityAnimation,
                  child: PanelMain(
                    currentTime: currentTime,
                    onRetirePressed: onRetirePressed,
                  ),
                ),
              ),

            // Menú inferior fijo
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: elementsOpacityAnimation,
                child: BottomMenu(
                  onProfilePressed: () {
                    // Acción de abrir popup perfil
                  },
                  onRoutesPressed: () {
                    // Acción menú rutas
                  },
                  onOtherPressed: () {
                    // Acción otra sección
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
