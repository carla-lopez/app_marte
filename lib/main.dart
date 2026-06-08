import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- Importamos Firebase
import 'package:marte_training/src/screens/common/login_screen.dart';

void main() async {
  // <--- Agregamos 'async' porque Firebase tarda unos milisegundos en arrancar
  // Esto asegura que el motor de Flutter esté listo antes de llamar a Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Le damos arranque a Firebase
  await Firebase.initializeApp();

  runApp(const MarteApp());
}

class MarteApp extends StatelessWidget {
  const MarteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marte Training',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
