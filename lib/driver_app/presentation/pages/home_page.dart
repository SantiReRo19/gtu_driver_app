// home_page.dart
import 'package:flutter/material.dart';
import 'dart:async';

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

  late AnimationController activeLabelPulseController;
  late Animation<double> activeLabelPulseAnimation;

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
          end: const Offset(0, -1.0), // sube hasta arriba
        ).animate(
          CurvedAnimation(
            parent: busMoveScaleController,
            curve: Curves.easeInOut,
          ),
        );

    busScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
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

    headerOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: headerOpacityController, curve: Curves.easeIn),
    );

    activeLabelPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    activeLabelPulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: activeLabelPulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    busMoveScaleController.dispose();
    buttonFadeController.dispose();
    headerOpacityController.dispose();
    activeLabelPulseController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void onStartPressed() {
    if (status != DriverStatus.inactive) return;

    buttonFadeController.forward().then((_) async {
      setState(() {
        status = DriverStatus.starting;
      });
      await busMoveScaleController.forward();
      setState(() {
        status = DriverStatus.active;
      });
      headerOpacityController.forward();
    });
  }

  void onRetirePressed() {
    // Popup confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Seguro que quieres retirarte del turno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retireTurn();
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _retireTurn() async {
    if (status != DriverStatus.active) return;

    // Reducir velocidad animación bus (simulo con reverse lento)
    await busMoveScaleController.reverse();

    setState(() {
      status = DriverStatus.offDuty;
    });
    buttonFadeController.reverse(); // Mostrar botón iniciar gris
    headerOpacityController.reset();
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
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: headerOpacityAnimation,
                child: const Center(
                  child: Text(
                    'Listo para comenzar el viaje',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),

            // Bus (imagen o gif) con animación
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedBuilder(
                animation: busMoveScaleController,
                builder: (_, __) {
                  return FractionalTranslation(
                    translation: busPositionAnimation.value,
                    child: Transform.scale(
                      scale: busScaleAnimation.value,
                      child:
                          status == DriverStatus.active ||
                              status == DriverStatus.starting
                          ? Image.asset(
                              'assets/bus.gif',
                              width: size.width,
                              fit: BoxFit.fitWidth,
                            )
                          : Image.asset(
                              'assets/bus.png',
                              width: size.width * 0.6,
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                  );
                },
              ),
            ),

            // Botón iniciar (redondo, parpadeante, cambio de color al presionar)
            if (status == DriverStatus.inactive ||
                status == DriverStatus.offDuty)
              Positioned(
                top: size.height * 0.45,
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
                top: size.height * 0.55,
                left: 0,
                right: 0,
                child: PanelMain(
                  currentTime: currentTime,
                  onRetirePressed: onRetirePressed,
                ),
              ),

            // Menú inferior fijo
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomMenu(
                onProfilePressed: () {
                  // Acción de abrir popup perfil (implementas tú)
                },
                onRoutesPressed: () {
                  // Acción menú rutas (implementas tú)
                },
                onOtherPressed: () {
                  // Acción otra sección
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// StartButtonRound con parpadeo y cambio de color
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
      begin: Colors.grey.shade400,
      end: widget.active ? Colors.grey.shade600 : Colors.grey.shade400,
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
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            elevation: 8,
          ),
          child: Text(
            'Iniciar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.active ? Colors.white : Colors.black38,
            ),
          ),
        );
      },
    );
  }
}

// Panel principal con hora, etiquetas y botón "En ruta"
class PanelMain extends StatelessWidget {
  final DateTime currentTime;
  final VoidCallback onRetirePressed;

  const PanelMain({
    super.key,
    required this.currentTime,
    required this.onRetirePressed,
  });

  String get formattedTime {
    final h = currentTime.hour.toString().padLeft(2, '0');
    final m = currentTime.minute.toString().padLeft(2, '0');
    final s = currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EF),
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
          const SizedBox(height: 12),
          // Etiqueta Activo parpadeante
          ActiveLabel(),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoItem(icon: Icons.map, label: 'Ruta: 45B'),
              InfoItem(icon: Icons.timer, label: 'Inicio: 7:00 AM'),
            ],
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: onRetirePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
            ),
            child: const Text(
              'En ruta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveLabel extends StatefulWidget {
  const ActiveLabel({super.key});

  @override
  State<ActiveLabel> createState() => _ActiveLabelState();
}

class _ActiveLabelState extends State<ActiveLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade700.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Text(
          'Activo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

// Menú inferior con 3 botones
class BottomMenu extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onRoutesPressed;
  final VoidCallback onOtherPressed;

  const BottomMenu({
    super.key,
    required this.onProfilePressed,
    required this.onRoutesPressed,
    required this.onOtherPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onRoutesPressed,
            icon: const Icon(Icons.route, size: 32, color: Colors.black54),
          ),
          IconButton(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person, size: 36, color: Colors.black87),
          ),
          IconButton(
            onPressed: onOtherPressed,
            icon: const Icon(Icons.menu, size: 32, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
