import 'package:flutter/material.dart';
import 'package:gtu_driver_app/driver_app/data/services/auth_service.dart';

class ResetPasswordDialog extends StatefulWidget {
  final AuthService authService;

  const ResetPasswordDialog({super.key, required this.authService});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final TextEditingController _resetEmailController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restablecer contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu correo electrónico:'),
          const SizedBox(height: 12),
          TextField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: loading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: loading
              ? null
              : () async {
                  final email = _resetEmailController.text.trim();

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa tu correo'),
                      ),
                    );
                    return;
                  }

                  setState(() => loading = true);

                  try {
                    await widget.authService.resetPassword(email);

                    if (context.mounted) {
                      Navigator.of(context).pop();

                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text('Correo enviado'),
                          content: Text(
                            'Revisa tu bandeja de entrada.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}