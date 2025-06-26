import 'package:flutter/material.dart';

class UpdatePasswordDrawer extends StatelessWidget {
  final void Function(String oldPassword, String newPassword) onUpdate;

  const UpdatePasswordDrawer({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: isSmallScreen ? 16 : 32,
            right: isSmallScreen ? 16 : 32,
            top: isSmallScreen ? 24 : 32,
            bottom: keyboardHeight > 0
                ? keyboardHeight
                : (isSmallScreen ? 24 : 32),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Actualizar contraseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 50, 167, 56),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPasswordField(
                        controller: oldPasswordController,
                        hint: 'Contraseña actual',
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: newPasswordController,
                        hint: 'Nueva contraseña',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            onUpdate(
                              oldPasswordController.text.trim(),
                              newPasswordController.text.trim(),
                            );
                            Navigator.pop(context); // Cierra el panel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Actualizar contraseña',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.green[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
