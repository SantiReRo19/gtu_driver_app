import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://api.gtuadmin.lat/api';

  // LOGIN
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] != 200) {
        throw Exception(data['message'] ?? 'Error de autenticación');
      }

      final user = data['data'];
      if (user['role'] != 'DRIVER') {
        throw Exception('Solo conductores pueden ingresar');
      }

      print(user);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user['accessToken']);
      await prefs.setString('userName', user['name']);
      await prefs.setString('userEmail', user['email']);
      await prefs.setString('userRole', user['role']);
      await prefs.setString('userId', user['userId'].toString());
      return true;
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en login');
      } catch (_) {
        throw Exception('Error desconocido: ${response.statusCode}');
      }
    }
  }

  // PERFIL (opcional, si necesitas datos extras)
  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('No se pudo obtener el perfil');
    }
  }

  // RESTABLECER CONTRASEÑA
  Future<void> resetPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/reset-password-request');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? 'Error al solicitar reset';
        throw Exception(msg);
      } catch (_) {
        throw Exception('Error desconocido al solicitar reset');
      }
    }
  }

  // CAMBIAR CONTRASEÑA
  Future<void> changePassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password');
    final response = await http.post(
      url,
      body: {'token': token, 'newPassword': newPassword},
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Error al cambiar contraseña',
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
