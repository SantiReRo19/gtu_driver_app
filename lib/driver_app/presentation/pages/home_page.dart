import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtu_driver_app/driver_app/data/services/routes_service.dart';
import 'package:gtu_driver_app/driver_app/presentation/pages/login.dart';
import 'package:gtu_driver_app/driver_app/presentation/widgets/profile_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/home/start_section.dart';
import '../widgets/home/panel_main.dart';
import '../widgets/home/bottom_menu.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/home/welcome_header.dart';
import '../widgets/driver_status.dart';
import '../../data/models/driver_data.dart';
import '../widgets/routes/bottom_routes_panel.dart';
import '../../data/services/web_socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DriverStatus status = DriverStatus.inactive;
  Websocketservice? _websocket;
  StreamSubscription? _locationSubscription;

  String? rutaAsignada;
  String? horaInicioTurnoStr;
  DateTime? horaInicioTurno;
  DateTime? horaFinTurno;
  Duration? duracionTurno;

  late AnimationController busMoveScaleController;
  late Animation<Offset> busPositionAnimation;
  late Animation<double> busScaleAnimation;

  late AnimationController buttonFadeController;
  late Animation<double> buttonFadeAnimation;

  late AnimationController headerOpacityController;
  late Animation<double> headerOpacityAnimation;

  late AnimationController elementsOpacityController;
  late Animation<double> elementsOpacityAnimation;

  late AnimationController panelFadeController;
  late Animation<double> panelFadeAnimation;

  late AnimationController finishTextController;
  late Animation<double> finishTextFadeAnimation;

  bool showFinishText = false;
  bool showStartText = false;
  bool showPanel = false;

  late Timer? timer;
  DateTime currentTime = DateTime.now();
  static const _eventChannel = EventChannel(
    "com.example.gtu_driver_app/stream_ubicacion",
  );
  static const _methodChannel = MethodChannel(
    "com.example.gtu_driver_app/bg_service",
  );

  String _formatHora(DateTime dt) {
    int hour = dt.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$hour:$m $ampm';
  }

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

    panelFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    panelFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: panelFadeController, curve: Curves.easeOut),
    );

    finishTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    finishTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: finishTextController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
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

  void onStartPressed() async {
    if (status != DriverStatus.inactive) return;

    setState(() {
      status = DriverStatus.starting;
      showPanel = false;
    });

    // 1. Cargar ruta asignada
    final routesService = RoutesService();
    final assignedRoutes = await routesService.getAssignedRoutes();
    String? nombreRuta;
    if (assignedRoutes.isNotEmpty) {
      final allRoutes = await routesService.getAllRoutes();
      final routeId = assignedRoutes[0]['routeId'];
      final route = allRoutes.firstWhere(
        (r) => r['id'] == routeId,
        orElse: () => null,
      );
      nombreRuta = route != null ? route['name'] : 'Ruta desconocida';
    }
    final now = DateTime.now();

    setState(() {
      rutaAsignada = nombreRuta ?? 'Sin ruta';
      horaInicioTurno = now;
      horaInicioTurnoStr = _formatHora(now);
    });

    // ...resto del flujo igual...
    _websocket = Websocketservice(
      driverId: "2",
      wsUrl: "wss://api.gtuadmin.lat/ws",
      onLocationReceived: (data) {},
    );
    _websocket!.connect();

    _startLocationListener();

    await buttonFadeController.forward();
    await busMoveScaleController.forward();

    setState(() {
      showStartText = true;
    });
    await finishTextController.forward();
    await Future.delayed(const Duration(seconds: 1));
    await finishTextController.reverse();
    setState(() {
      showStartText = false;
      status = DriverStatus.active;
      showPanel = true;
    });

    panelFadeController.value = 0.0;
    await panelFadeController.forward();
    elementsOpacityController.forward();
    await _startLocationService();
  }

  void onRetirePressed() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Confirmación',
        content: '¿Seguro que quieres finalizar el turno?',
        onConfirm: _retireTurn,
      ),
    );
  }

  void _retireTurn() async {
    if (status != DriverStatus.active) return;

    await _stopLocationService();
    _websocket?.disconnect();
    _websocket = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;

    // 1. Desvanece el panel
    await panelFadeController.reverse();

    // 2. Mueve el bus al centro (animación reversa)
    await busMoveScaleController.reverse();

    // 3. Calcula duración del turno
    final fin = DateTime.now();
    horaFinTurno = fin;
    if (horaInicioTurno != null) {
      duracionTurno = fin.difference(horaInicioTurno!);
    } else {
      duracionTurno = null;
    }

    // 4. Muestra el mensaje "Buen trabajo"
    setState(() {
      showFinishText = true;
    });
    await finishTextController.forward();

    // 5. Espera 2 segundos con el mensaje visible y blur
    await Future.delayed(const Duration(seconds: 2));

    // 6. Oculta el mensaje y vuelve a estado inactivo
    await finishTextController.reverse();
    setState(() {
      showFinishText = false;
      status = DriverStatus.inactive;
      showPanel = false;
    });

    // 7. Restaura el header para que WelcomeHeader sea visible
    panelFadeController.value = 0.0;
    headerOpacityController.value = 1.0;
    elementsOpacityController.value = 0.0;
  }

  void _startLocationListener() {
    _locationSubscription?.cancel();
    _locationSubscription = _eventChannel.receiveBroadcastStream().listen(
      (location) {
        // location: "lat,lon"
        final parts = location.toString().split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0]);
          final lon = double.tryParse(parts[1]);
          if (lat != null && lon != null && _websocket != null) {
            _websocket!.sendLocation(lat, lon);
          }
        }
      },
      onError: (error) {
        log("Error al recibir ubicación: $error");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Header de bienvenida SIEMPRE visible cuando corresponde
            if ((status == DriverStatus.inactive ||
                    status == DriverStatus.offDuty) &&
                !showFinishText &&
                !showStartText)
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: WelcomeHeader(
                  opacity: AlwaysStoppedAnimation(1.0),
                  text: '¿Estas listo?',
                ),
              ),

            // Sección de inicio LOGO, BUS Y BOTÓN
            StartSection(
              status: status,
              busPositionAnimation: busPositionAnimation,
              busScaleAnimation: busScaleAnimation,
              onStartPressed: onStartPressed,
              buttonActive: status == DriverStatus.offDuty ? false : true,
            ),

            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/logoblue.png',
                  width: 70,
                  height: 70,
                ),
              ),
            ),

            // Panel principal (solo si showPanel es true y no hay overlays)
            if (showPanel &&
                status != DriverStatus.inactive &&
                status != DriverStatus.offDuty &&
                !showFinishText &&
                !showStartText)
              Positioned(
                top: size.height * 0.4,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: panelFadeAnimation,
                  child: PanelMain(
                    currentTime: currentTime,
                    status: status,
                    onRetirePressed: onRetirePressed,
                    onStartPressed: onStartPressed,
                    rutaAsignada: rutaAsignada,
                    horaInicioTurnoStr: horaInicioTurnoStr,
                  ),
                ),
              ),

            // Overlay de mensaje "Buen trabajo, turno finalizado" con blur y animación
            if (showFinishText)
              Positioned.fill(
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.black.withOpacity(0.1)),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: finishTextFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "¡Buen trabajo, turno finalizado!",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5096C2),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (duracionTurno != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Hiciste un turno de ${duracionTurno!.inHours} horas y ${duracionTurno!.inMinutes.remainder(60)} minutos.",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Overlay de mensaje "Turno iniciado" con blur y animación
            if (showStartText)
              Positioned.fill(
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.black.withOpacity(0.1)),
                    ),
                    Center(
                      child: FadeTransition(
                        opacity: finishTextFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Text(
                            "¡Turno iniciado!",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5096C2),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Menú inferior SIEMPRE visible y solo con dos botones
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomMenu(
                onProfilePressed: () async {
                  final driverData = await getDriverData();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ProfileDrawer(
                      name: driverData['name'] ?? '',
                      email: driverData['email'] ?? '',
                      role: driverData['role'] ?? '',
                      onLogout: _handleLogout,
                      status: status,
                    ),
                  );
                },
                onRoutesPressed: () {
                  showRoutesPanel(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;

    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("La app necesita acceso a la ubicación.")),
        );
      }
    }
  }

  Future<void> _startLocationService() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      await _methodChannel.invokeMethod("startService");
    } else {
      final result = await Permission.location.request();

      if (result.isGranted) {
        await _methodChannel.invokeMethod("startService");
      } else if (result.isPermanentlyDenied) {
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Permiso denegado permanentemente. Ábrelo desde ajustes.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permiso de ubicación no concedido.")),
        );
      }
    }
  }

  Future<void> _stopLocationService() async {
    try {
      await _methodChannel.invokeMethod("stopService");
    } catch (e) {
      print("Error al detener el servicio: $e");
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cerrar sesión',
        content: '¿Seguro que quieres cerrar sesión?',
        onConfirm: _logoutWithAnimation,
      ),
    );
  }

  void _logoutWithAnimation() async {
    // Animación de salida para todos los elementos
    await Future.wait([
      panelFadeController.reverse(),
      elementsOpacityController.reverse(),
      headerOpacityController.reverse(),
      buttonFadeController.reverse(),
      busMoveScaleController.reverse(),
    ]);

    // Espera un poco para que la animación se vea fluida
    await Future.delayed(const Duration(milliseconds: 300));

    // Navega al login (elimina todo el stack)
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    }
  }
}
