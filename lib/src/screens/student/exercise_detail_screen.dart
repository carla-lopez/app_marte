import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ejercicio;

  const ExerciseDetailScreen({super.key, required this.ejercicio});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  // Aquí guardamos los controladores de texto para cada serie
  List<Map<String, TextEditingController>> _controllers = [];
  bool _guardando = false;

  // ⚠️⚠️⚠️ ¡IMPORTANTE! PONÉ TU IP REAL AQUÍ ⚠️⚠️⚠️
  static const String ip = "192.168.0.116";

  @override
  void initState() {
    super.initState();
    // 1. Inicializamos los campos de texto con los datos que vienen de la base
    final series = widget.ejercicio['series'] as List;
    for (var serie in series) {
      _controllers.add({
        "kg": TextEditingController(text: serie['kg_real']?.toString() ?? ""),
        "reps": TextEditingController(
          text: serie['reps_real']?.toString() ?? "",
        ),
        "rpe": TextEditingController(text: serie['rpe_real']?.toString() ?? ""),
      });
    }
  }

  @override
  void dispose() {
    // Limpiamos la memoria al salir
    for (var row in _controllers) {
      row['kg']!.dispose();
      row['reps']!.dispose();
      row['rpe']!.dispose();
    }
    super.dispose();
  }

  // --- FUNCIÓN PARA GUARDAR EN LA BASE DE DATOS ---
  Future<void> _guardarDatos() async {
    setState(() => _guardando = true);
    final url = Uri.parse('http://$ip:8000/actualizar-series');

    try {
      // A. Armamos la lista de datos limpia para mandar a Python
      List<Map<String, dynamic>> listaParaEnviar = [];
      final seriesData = widget.ejercicio['series'] as List;

      for (int i = 0; i < seriesData.length; i++) {
        // Obtenemos el ID único de la serie (fundamental para el UPDATE)
        int idUnico = seriesData[i]['id'];

        // Obtenemos lo que escribió el usuario en los casilleros
        String kgTxt = _controllers[i]['kg']!.text;
        String repsTxt = _controllers[i]['reps']!.text;
        String rpeTxt = _controllers[i]['rpe']!.text;

        listaParaEnviar.add({
          "id_serie": idUnico,
          "kg": double.tryParse(kgTxt), // Convertimos texto a número
          "reps": int.tryParse(repsTxt),
          "rpe": int.tryParse(rpeTxt),
        });
      }

      // B. Enviamos el paquete al Backend (PUT)
      final respuesta = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(listaParaEnviar),
      );

      if (respuesta.statusCode == 200) {
        if (!mounted) return;
        // ÉXITO: Mostramos cartel verde y volvemos atrás
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Guardado exitoso! ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Error del servidor: ${respuesta.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ejercicio['nombre_ejercicio']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INFO TÉCNICA (Caja azulita)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  // MUESTRA EL MÚSCULO SI EXISTE EN LA BASE
                  if (widget.ejercicio['grupo_muscular'] != null) ...[
                    _DatoTecnico("Zona:", widget.ejercicio['grupo_muscular']),
                    const Divider(height: 10),
                  ],

                  _DatoTecnico(
                    "Técnica:",
                    widget.ejercicio['tecnica_nota'] ?? "-",
                  ),
                  const SizedBox(height: 5),
                  _DatoTecnico(
                    "Descanso:",
                    "${widget.ejercicio['descanso_segundos']} seg",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. TABLA (Encabezados)
            const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    "#",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "KG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "REPS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "RPE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // 3. FILAS DE INPUTS (Donde escribe Carla)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controllers.length,
              separatorBuilder: (c, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    // Número de serie (bolita gris)
                    SizedBox(
                      width: 40,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Casilleros para escribir
                    Expanded(
                      child: _InputCelda(
                        controller: _controllers[index]['kg']!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputCelda(
                        controller: _controllers[index]['reps']!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputCelda(
                        controller: _controllers[index]['rpe']!,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // 4. BOTÓN NEGRO DE GUARDAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_guardando ? "GUARDANDO..." : "GUARDAR DATOS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: _guardando
                    ? null
                    : _guardarDatos, // <--- Aquí se activa la magia
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets auxiliares para que quede lindo
class _DatoTecnico extends StatelessWidget {
  final String label;
  final String valor;
  const _DatoTecnico(this.label, this.valor);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _InputCelda extends StatelessWidget {
  final TextEditingController controller;
  const _InputCelda({required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
