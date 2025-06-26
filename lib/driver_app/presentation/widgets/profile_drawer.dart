import 'package:flutter/material.dart';
import 'package:gtu_driver_app/driver_app/presentation/widgets/update_password.dart';

class ProfileDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String status = 'Conectado';
  final String? imageUrl;

  const ProfileDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
  });

  bool get isConnected => false; // Simulación de estado de conexión

  void showUpdatePasswordDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdatePasswordDrawer(
        onUpdate: (oldPass, newPass) {
          // Aquí puedes hacer la petición al backend para cambiar la contraseña
          print('Contraseña anterior: $oldPass');
          print('Nueva contraseña: $newPass');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 252, 252, 252),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                      fontSize: 18,
                      color: isConnected
                          ? const Color.fromARGB(255, 33, 216, 140)
                          : const Color.fromARGB(255, 106, 56, 36),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isConnected
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildTile(context, Icons.person_outline, 'Tu perfil'),
                    _buildTile(
                      context,
                      Icons.privacy_tip_outlined,
                      'Política de privacidad',
                    ),
                    _buildTile(context, Icons.update, 'Actualizar contraseña'),
                    const Divider(),
                    _buildTile(
                      context,
                      Icons.logout,
                      'Cerrar sesión',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title, {
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Acción por item
        if (title == 'Actualizar contraseña') {
          showUpdatePasswordPanel(context);
        } else if (title == 'Cerrar sesión') {
          // Aquí puedes implementar la lógica para cerrar sesión
          print('Cerrar sesión');
        } else {
          print('Navegar a $title');
        }
      },
    );
  }

  void showUpdatePasswordPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdatePasswordDrawer(
        onUpdate: (oldPass, newPass) {
          // Aquí puedes hacer la petición al backend para cambiar la contraseña
          print('Contraseña anterior: $oldPass');
          print('Nueva contraseña: $newPass');
        },
      ),
    );
  }
}
