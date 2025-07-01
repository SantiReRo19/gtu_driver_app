import 'package:flutter/material.dart';
import '../../../data/services/routes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomRoutesPanel extends StatefulWidget {
  const BottomRoutesPanel({super.key});

  @override
  State<BottomRoutesPanel> createState() => _BottomRoutesPanelState();
}

class _BottomRoutesPanelState extends State<BottomRoutesPanel> {
  final RoutesService _routesService = RoutesService();

  // Variable para almacenar el nombre de usuario
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });
  }

  Future<Map<String, dynamic>> fetchRoutesData() async {
    try {
      // Obtén la ruta asignada al conductor
      final myRoute = await _routesService.getAssignedRoutes();
      final allRoutes = await _routesService.getAllRoutes();

      // Busca la ruta asignada al conductor usando el nombre (ajusta según modelo real)

      return {'myRoute': myRoute, 'allRoutes': allRoutes};
    } catch (e) {
      throw Exception('Error al cargar las rutas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchRoutesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar las rutas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final myRoute = snapshot.data?['myRoute'];
        final allRoutes = snapshot.data?['allRoutes'] as List<dynamic>? ?? [];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  'Rutas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),

                // Mi Ruta de Hoy
                const Text(
                  'Mi Ruta de Hoy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),

                myRoute != null
                    ? ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          allRoutes.firstWhere(
                                (e) => e['id'] == myRoute[0]['routeId'],
                              )['name'] ??
                              'Ruta desconocida',
                          style: TextStyle(
                            backgroundColor: Colors.green[100],
                            color: Colors.green[900],
                          ),
                        ),
                        children: [
                          //if (myRoute['description'] != null)
                          ...allRoutes
                              .where((e) => e['id'] == myRoute[0]['routeId'])
                              .map(
                                (e) => ListTile(
                                  title: Text(
                                    'Descripción: ${e['description'] ?? 'No disponible'}',
                                  ),
                                ),
                              ),

                          ListTile(title: Text('Conductor: $userName')),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No tienes ruta asignada hoy.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                const SizedBox(height: 24),

                // Otras rutas
                const Text(
                  'Otras Rutas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),

                if (allRoutes.isEmpty)
                  const Text(
                    'No hay rutas registradas.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ...allRoutes
                    .where(
                      (e) =>
                          (myRoute == null) ||
                          (e['id'] != myRoute[0]['routeId']),
                    )
                    .map(
                      (e) => ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          '${e['name'] ?? 'Desconocida'}',
                          style: TextStyle(
                            backgroundColor: Colors.blue[50],
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          if (e['description'] != null)
                            ListTile(
                              title: Text('Descripción: ${e['description']}'),
                            ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Función para abrir el panel desde cualquier parte de la app (por ejemplo, desde la barra de navegación inferior)
void showRoutesPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const BottomRoutesPanel(),
  );
}
