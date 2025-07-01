import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.onLogin,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logoblue.png', width: 150, height: 150),
          //const SizedBox(height: 8),
          const Text(
            'GTU',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inicio de sesión',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              filled: true,
              fillColor: Colors.blue[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              filled: true,
              fillColor: Colors.blue[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 52, 112, 152),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: loading ? null : onLogin,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: loading ? null : onResetPassword,
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: Color.fromARGB(255, 52, 112, 152),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
