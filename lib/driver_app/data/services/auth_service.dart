import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://backend.com'; 

  // LOGIN
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data']['role'] != 'DRIVER') {
        throw Exception('Solo conductores pueden ingresar');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['accessToken']);
      await prefs.setString('userName', data['data']['name']);
      await prefs.setString('userEmail', data['data']['email']);
      await prefs.setString('userRole', data['data']['role']);
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error en login');
    }
  }

  // PERFIL (opcional, si necesitas datos extras)
  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('No se pudo obtener el perfil');
    }
  }

  // RESTABLECER CONTRASEÑA
  Future<void> resetPassword(String email) async {
    final url = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(url, body: {'email': email});

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al solicitar reset');
    }
    // Si el backend envía un email, aquí termina el proceso.
  }

  // CAMBIAR CONTRASEÑA
  Future<void> changePassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password');
    final response = await http.post(url, body: {
      'token': token,
      'newPassword': newPassword,
    });

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error al cambiar contraseña');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}