import 'package:flutter/material.dart';
import 'package:marte_training/src/screens/common/login_screen.dart';
import 'package:marte_training/src/screens/student/tabs/info_tab.dart';
import 'package:marte_training/src/screens/student/tabs/timer_tab.dart'; // <--- IMPORTAMOS TU TIMER REAL
import 'package:marte_training/src/screens/student/tabs/calc_tab.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final String rol;

  const HomeScreen({super.key, required this.nombreUsuario, required this.rol});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas conectadas
  final List<Widget> _widgetOptions = <Widget>[
    const InfoTab(), // 0. Inicio / Pizarrón
    const Center(child: Text("Planis Temporal")), // 1. Planificaciones
    const TimerTab(), // 2. ¡TU TIMER REAL CONECTADO!
    const CalcTab(), // 3. Calculadora RM
  ];

  void _logout() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "MARTE TRAINING",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'perfil',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Perfil Personal'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'mensajes',
                  child: ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Mensajes'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'cuota',
                  child: ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Estado de Cuota'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black87),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hola, ${widget.nombreUsuario}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.accessibility_new),
              title: const Text('Guía de Movilidad'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_filled, color: Colors.red),
              title: const Text('Canal de YouTube'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Beneficios'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Progresiones'),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: _widgetOptions[_selectedIndex],

      // BOTÓN FLOTANTE: WhatsApp (Visible SOLO en la pestaña 0 - Inicio)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Lógica para abrir WhatsApp luego
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.wechat, color: Colors.white, size: 30),
            )
          : null, // Si es cualquier otra pestaña, no mostramos nada

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Colors.blue.shade100,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planis',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calc',
          ),
        ],
      ),
    );
  }
}
