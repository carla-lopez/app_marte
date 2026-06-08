import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marte_training/src/screens/student/exercise_detail_screen.dart';
import 'dart:convert';
import 'package:marte_training/src/screens/student/wod_screen.dart';

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  bool _cargando = true;
  Map<String, dynamic>? _rutinaData;
  String _mensajeError = "";

  // ⚠️ TU IP REAL
  static const String ip = "192.168.0.116";
  final int alumnoId = 2;

  @override
  void initState() {
    super.initState();
    _cargarRutina();
  }

  // Esta función es la que va a buscar los datos frescos
  Future<void> _cargarRutina() async {
    // Si queremos que se note que está cargando, descomentar la siguiente línea:
    // setState(() => _cargando = true);

    final url = Uri.parse('http://$ip:8000/rutina/$alumnoId');

    try {
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        if (data['dias'] != null) {
          setState(() {
            _rutinaData = data;
            _cargando = false;
          });
        } else {
          setState(() {
            _mensajeError = "No se encontró una planificación activa.";
            _cargando = false;
          });
        }
      } else {
        setState(() {
          _mensajeError = "Error del servidor: ${respuesta.statusCode}";
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _mensajeError = "Error de conexión: $e";
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mensajeError.isNotEmpty) {
      return Center(
        child: Text(_mensajeError, style: const TextStyle(color: Colors.red)),
      );
    }

    final List dias = _rutinaData!['dias'];
    final infoRutina = _rutinaData!['info_rutina'];

    return Column(
      children: [
        // Cabecera Negra
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Microciclo: ${infoRutina['microciclo']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Semana ${infoRutina['semanas_transcurridas']}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        // Lista de Días
        Expanded(
          child: ListView.builder(
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              // ACÁ ESTÁ LA CLAVE: Le pasamos la función _cargarRutina a la tarjeta
              return _TarjetaDia(
                dia: dia,
                onRecargar:
                    _cargarRutina, // <--- ¡Pasamos el "refresco" para abajo!
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget TarjetaDia modificado para aceptar el refresco
class _TarjetaDia extends StatelessWidget {
  final Map<String, dynamic> dia;
  final VoidCallback onRecargar; // <--- Nueva variable para recibir la orden

  const _TarjetaDia({
    required this.dia,
    required this.onRecargar, // <--- Obligatorio
  });

  @override
  Widget build(BuildContext context) {
    final List ejercicios = dia['ejercicios'];

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: ExpansionTile(
        backgroundColor: Colors.cyan.shade50,
        collapsedBackgroundColor: Colors.cyan,
        title: Text(
          "DÍA ${dia['numero_dia']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text("Duración: ${dia['duracion_minutos']} min"),
        children: [
          if (dia['notas_atleta'] != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "📝 ${dia['notas_atleta']}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

          ...ejercicios.map((ej) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black87,
                child: Text(
                  ej['orden_letra'] ?? "${ej['orden_numerico']}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                ej['nombre_ejercicio'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${ej['series'].length} Series | ${ej['rpe_objetivo']}",
              ),
              trailing: const Icon(Icons.chevron_right),

              // --- EL SEMAFORO INTELIGENTE ---
              onTap: () async {
                // 1. Preguntamos : ¿Es un wod?
                // (La base de datos puede devolver 1/0 o true/false,chequeamos ambos por las dudas)
                bool esWod = ej['es_wod'] == 1 || ej['es_wod'] == true;

                if (esWod) {
                  // --- OPCION A: ES CROSSFIT / WOD ---
                  // Como todavia no creamos la pantalla del Timer, mostramos un aviso.
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WodScreen(ejercicio: ej),
                    ),
                  );
                } else {
                  // --- OPCION B: ES EJERCICIO MUSCULACION NORMAL ---
                  // Navegamos a la pantalla de series que ya se creo

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseDetailScreen(ejercicio: ej),
                    ),
                  );

                  //Al volver, recargamos para ver si cambiasto los pesos
                  print("Volviendo de musculacion... Recargando datos...");
                  onRecargar();
                }

                // 2. Cuando vuelve (Navigator.pop allá), ejecutamos esto:
                print("Volviendo... Recargando datos...");
                onRecargar(); // <--- ¡Pedimos los datos nuevos a Python!
              },
            );
          }).toList(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
