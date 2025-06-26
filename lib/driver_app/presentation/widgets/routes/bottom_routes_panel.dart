import 'package:flutter/material.dart';
import '../../../data/services/routes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomRoutesPanel extends StatefulWidget {
  const BottomRoutesPanel({Key? key}) : super(key: key);

  @override
  State<BottomRoutesPanel> createState() => _BottomRoutesPanelState();
}

class _BottomRoutesPanelState extends State<BottomRoutesPanel> {
  late Future<Map<String, dynamic>> dataFuture;
  final RoutesService _routesService = RoutesService();

  @override
  void initState() {
    super.initState();
    dataFuture = fetchRoutesData();
  }

  Future<Map<String, dynamic>> fetchRoutesData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? '';

    // Obtén la ruta asignada al conductor
    final allRoutes = await _routesService.getAssignedRoutes();

    // Busca la ruta asignada al conductor usando el nombre (ajusta según modelo real)
    final myRoute = allRoutes.firstWhere(
      (r) => r['assignedDriverName'] == userName,
      orElse: () => <String, dynamic>{},
    );

    return {
      'myRoute': myRoute,
      'allRoutes': allRoutes,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final myRoute = snapshot.data?['myRoute'] as Map<String, dynamic>?;
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
                const Text('Rutas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),

                // Mi Ruta de Hoy
                const Text('Mi Ruta de Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                myRoute != null
                    ? ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          (myRoute['routeName'] ?? 'Ruta desconocida'),
                          style: TextStyle(
                            backgroundColor: Colors.green[100],
                            color: Colors.green[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          if (myRoute['description'] != null)
                            ListTile(
                              title: Text('Descripción: ${myRoute['description']}'),
                            ),
                          ListTile(
                            title: Text('Conductor: ${myRoute['assignedDriverName'] ?? "Sin asignar"}'),
                          ),
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
                const Text('Otras Rutas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                if (allRoutes.isEmpty)
                  const Text('No hay rutas registradas.', style: TextStyle(color: Colors.grey)),
                ...allRoutes.where((e) =>
                        (myRoute == null) ||
                        (e['routeName'] != myRoute['routeName'] || e['assignedDriverName'] != myRoute['assignedDriverName']))
                    .map((e) => ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            (e['routeName'] ?? 'Ruta desconocida'),
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
                            ListTile(
                              title: Text('Conductor asignado: ${e['assignedDriverName'] ?? "Sin asignar"}'),
                            ),
                          ],
                        )),
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