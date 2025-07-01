import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoutesService {
  final String baseUrl = 'https://api.gtuadmin.lat/api';

  Future<void> startRoute(String routeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/assign-driver');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'routeId': routeId}),
    );

    if (response.statusCode == 200) {
      print('Ruta iniciada correctamente: ${response.body}');
      // Ruta iniciada correctamente
      return;
    } else if (response.statusCode == 401) {
      // Token inválido o expirado
      await prefs.clear();
      throw Exception('Sesión expirada, vuelve a iniciar sesión');
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Error al iniciar ruta',
      );
    }
  }

  // LISTAR RUTAS ASIGNADAS AL CONDUCTOR AUTENTICADO
  Future<List<Map<String, dynamic>>> getAssignedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final url = Uri.parse('$baseUrl/assign-driver/assignments/driver/$userId');
    if (kDebugMode) {
      print('URL: $url');
      print('Token: $token');
      print('User ID: $userId');
    }

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response data: $data');
      }

      return [data['data'] as Map<String, dynamic>];
    } else if (response.statusCode == 401) {
      // Token inválido o expirado
      await prefs.clear();
      throw Exception('Sesión expirada, vuelve a iniciar sesión');
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Error al obtener rutas',
      );
    }
  }

  Future<List<dynamic>> getAllRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/route-management/routes');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (kDebugMode) {
      print('Response data: $data');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response data: $data');
      }
      return data['data'] as List<dynamic>;
    } else {
      final data = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response data: $data');
      }
      throw Exception('Error al obtener todas las rutas');
    }
  }

  Future<String?> getDriverName(int driverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
      '$baseUrl/assign-driver/assignments/driver/$driverId',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (kDebugMode) {
      print('Response data: $data');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['name'] as String?;
    }
    return null;
  }

  Future<String?> startTrackingSessionId(String driverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/driver-tracker/tracking/start/$driverId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response data Start Trackin: $data');
      }
      return data['data']['sessionId'] as String?;
    }
    if (kDebugMode) {
      print('Error al obtener sessionId: ${response.body}');
    }
    return null;
  }

  Future<void> endTrackingSessionId(String routeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/driver-tracker/tracking/stop/$routeId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Tracking succededs ${response.body}');
      }
      // Ruta finalizada correctamente
      return;
    } else if (response.statusCode == 401) {
      // Token inválido o expirado
      //await prefs.clear();
      throw Exception('Sesión expirada, vuelve a iniciar sesión');
    } else {
      if (kDebugMode) {
        print('Error apagando: ${response.body}');
      }
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Error al finalizar ruta',
      );
    }
  }
}
