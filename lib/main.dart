import 'package:flutter/material.dart';
import 'driver_app/presentation/pages/login.dart';

void main() {
  runApp(const BusDriverApp());
}

class BusDriverApp extends StatelessWidget {
  const BusDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5FBF7A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF4A90E2),
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      home: const Login(),
    );
  }
}
