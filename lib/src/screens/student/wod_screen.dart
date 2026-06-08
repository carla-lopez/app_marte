import 'package:flutter/material.dart';
import 'dart:async'; // Necesario para el Timer

class WodScreen extends StatefulWidget {
  final Map<String, dynamic> ejercicio;

  const WodScreen({super.key, required this.ejercicio});

  @override
  State<WodScreen> createState() => _WodScreenState();
}

class _WodScreenState extends State<WodScreen> {
  // VARIABLES DEL CRONÓMETRO
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _tiempoMostrado = "00:00";

  // INPUT PARA EL RESULTADO
  final TextEditingController _resultadoController = TextEditingController();

  @override
  void dispose() {
    _stopwatch.stop(); // Frenar reloj si salimos
    _timer.cancel(); // Matar el proceso del timer
    _resultadoController.dispose();
    super.dispose();
  }

  // --- LÓGICA DEL CRONÓMETRO ---
  void _iniciarPausar() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
        // Actualizamos la pantalla cada 1 segundo
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return; // Seguridad por si salimos de la pantalla
          setState(() {
            _tiempoMostrado = _formatearTiempo(_stopwatch.elapsedMilliseconds);
          });
        });
      }
    });
  }

  void _resetear() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _tiempoMostrado = "00:00";
    });
  }

  String _formatearTiempo(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    bool corriendo = _stopwatch.isRunning;

    return Scaffold(
      backgroundColor: Colors.grey[900], // Fondo oscuro estilo "Modo Bestia"
      appBar: AppBar(
        title: Text(widget.ejercicio['nombre_ejercicio']),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. DESCRIPCIÓN DEL WOD (Tarjeta Estilo Pizarra)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WORKOUT OF THE DAY",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.ejercicio['descripcion'] ??
                        "Sin descripción. ¡Dalo todo!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 2. EL CRONÓMETRO GIGANTE
            Text(
              _tiempoMostrado,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier', // Fuente tipo reloj digital
              ),
            ),

            const SizedBox(height: 20),

            // BOTONES PLAY / STOP / RESET
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Reset (Chiquito)
                IconButton(
                  onPressed: _resetear,
                  icon: const Icon(Icons.refresh, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 20),
                // Botón Principal (Play/Pausa)
                GestureDetector(
                  onTap: _iniciarPausar,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corriendo ? Colors.red : Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: (corriendo ? Colors.red : Colors.green)
                              .withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(
                      corriendo ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 50), // Espacio para equilibrar
              ],
            ),

            const SizedBox(height: 50),

            // 3. INPUT DE RESULTADO
            TextField(
              controller: _resultadoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Tu Resultado (Tiempo o Rondas)",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.emoji_events,
                  color: Colors.orange,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  // Lógica de guardado pendiente (próximo paso)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("¡Resultado registrado! (Simulado)"),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "TERMINAR WOD",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
