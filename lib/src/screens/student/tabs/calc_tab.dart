import 'package:flutter/material.dart';

class CalcTab extends StatefulWidget {
  const CalcTab({super.key});

  @override
  State<CalcTab> createState() => _CalcTabState();
}

class _CalcTabState extends State<CalcTab> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  double _rmCalculado = 0.0;

  void _calcularRM() {
    // Escondemos el teclado
    FocusScope.of(context).unfocus();

    final String pesoTexto = _pesoController.text.replaceAll(',', '.');
    final String repsTexto = _repsController.text;

    if (pesoTexto.isEmpty || repsTexto.isEmpty) return;

    final double peso = double.tryParse(pesoTexto) ?? 0.0;
    final int reps = int.tryParse(repsTexto) ?? 0;

    if (peso > 0 && reps > 0) {
      setState(() {
        if (reps == 1) {
          _rmCalculado = peso;
        } else {
          // Fórmula de Epley
          _rmCalculado = peso * (1 + (reps / 30));
        }
      });
    }
  }

  void _limpiar() {
    setState(() {
      _pesoController.clear();
      _repsController.clear();
      _rmCalculado = 0.0;
    });
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Evita que el teclado rompa el diseño
      resizeToAvoidBottomInset: false, 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarjeta de Ingreso de Datos
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "CALCULAR RM",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pesoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: "Peso (kg)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.fitness_center),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Repeticiones",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _limpiar,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text("LIMPIAR"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _calcularRM,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("CALCULAR", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resultado y Porcentajes
            if (_rmCalculado > 0) ...[
              // Banner del 100%
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("TU 1 REP MÁXIMA (100%)", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      "${_rmCalculado.toStringAsFixed(1)} kg",
                      style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de Porcentajes
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: 9, // Del 90% al 50%
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      // Calculamos del 90% bajando de a 5%
                      int porcentaje = 95 - (index * 5); 
                      double pesoPorcentaje = _rmCalculado * (porcentaje / 100);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text("$porcentaje%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        title: Text(
                          "${pesoPorcentaje.toStringAsFixed(1)} kg",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              // Mensaje vacío
              const Expanded(
                child: Center(
                  child: Text(
                    "Ingresá tus datos para ver\nlos porcentajes de trabajo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}