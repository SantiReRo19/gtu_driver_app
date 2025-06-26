import 'package:flutter/material.dart';
import 'package:gtu_driver_app/driver_app/data/services/auth_service.dart';
import 'home_page.dart';
import '../widgets/login/login_form.dart';
import '../widgets/login/reset_password_dialog.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _loading = false;

  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 0.0,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() => _loading = false);
        await _fadeController.reverse();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      // Manejo de error aquí si lo deseas
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResetPasswordDialog(authService: _authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: LoginForm(
              emailController: _emailController,
              passwordController: _passwordController,
              loading: _loading,
              onLogin: _handleLogin,
              onResetPassword: _showResetPasswordDialog,
            ),
          ),
        ),
      ),
    );
  }
}
