import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoutesService {
  final String baseUrl = 'https://api.gtuadmin.lat/api'; 

  // LISTAR RUTAS ASIGNADAS AL CONDUCTOR AUTENTICADO
  Future<List<Map<String, dynamic>>> getAssignedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/driver/routes');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Asume que data['data'] es una lista de rutas
      return List<Map<String, dynamic>>.from(data['data']);
    } else if (response.statusCode == 401) {
      // Token inválido o expirado
      await prefs.clear();
      throw Exception('Sesión expirada, vuelve a iniciar sesión');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al obtener rutas');
    }
  }

  Future<List<Map<String, dynamic>>> getAllRoutes() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrl/routes');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });
  if (kDebugMode) {
    print('Response status: ${response.statusCode}');
  }

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Error al obtener todas las rutas');
  }
}
}