import 'package:flutter/material.dart';
import 'home_page.dart';

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
        primaryColor: const Color(0xFF5FBF7A), // Light green
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF4A90E2), // Blue
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
      home: const HomePage(),
    );
  }
}
