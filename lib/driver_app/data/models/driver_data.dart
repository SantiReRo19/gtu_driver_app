import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> getDriverData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'id': prefs.getString('userId') ?? '',
    'name': prefs.getString('userName') ?? '',
    'email': prefs.getString('userEmail') ?? '',
    'role': prefs.getString('userRole') ?? '',
  };
}