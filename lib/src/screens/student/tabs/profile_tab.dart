import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FOTO DE PERFIL (Círculo con icono por ahora)
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 60, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),

          // NOMBRE DEL ALUMNO
          const Text(
            "Carla (Alumna)",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Plan: Musculación + CrossFit",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),

          const SizedBox(height: 40),

          // OPCIONES (Lista simple)
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Historial de Pagos"),
            onTap: () {},
          ),

          const Divider(),

          // BOTÓN CERRAR SESIÓN
          TextButton.icon(
            onPressed: () {
              // Acá luego pondremos la lógica para salir
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              "Cerrar Sesión",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
