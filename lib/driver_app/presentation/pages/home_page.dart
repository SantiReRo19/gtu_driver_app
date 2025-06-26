import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gtu_driver_app/driver_app/presentation/widgets/profile_drawer.dart';
import '../widgets/home/start_section.dart';
import '../widgets/home/panel_main.dart';
import '../widgets/home/bottom_menu.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/home/welcome_header.dart';
import '../widgets/driver_status.dart';
import '../../data/models/driver_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

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

    // Animaciones
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
      duration: const Duration(milliseconds: 1500),
      value: 1.0,
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
    headerOpacityController.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Header de bienvenida
            if (status == DriverStatus.inactive ||
                status == DriverStatus.offDuty)
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: WelcomeHeader(
                  opacity: headerOpacityAnimation,
                  text: '¿Estas listo?',
                ),
              ),

            // Sección de inicio (bus + botón)
            StartSection(
              status: status,
              busPositionAnimation: busPositionAnimation,
              busScaleAnimation: busScaleAnimation,
              onStartPressed: onStartPressed,
              buttonActive: status == DriverStatus.offDuty ? false : true,
            ),

            // Panel principal (hora, estado, ruta y botón "En ruta")
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
                  onProfilePressed: () async {
                    final driverData = await getDriverData();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ProfileDrawer(
                        name: driverData['name'] ?? '',
                        email: driverData['email'] ?? '',
                        role: driverData['role'] ?? '',
                      ),
                    );
                  },
                  onRoutesPressed: () {},
                  onOtherPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
