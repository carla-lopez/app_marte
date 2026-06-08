import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marte_training/src/screens/student/tabs/timer_running_screen.dart';


class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  // Valores por defecto (como en tu captura)
  int _prepare = 10;
  int _work = 20;
  int _rest = 10;
  int _cycles = 8;
  int _sets = 1;
  int _restBetweenSets = 0;
  int _coolDown = 0;

  // Calcula el tiempo total estimado
  String get _totalTimeFormatted {
    // Cálculo aproximado: 
    // Prep + [(Trabajo + Descanso) * Ciclos * Series] + Enfriamiento
    // (Ajustamos para no contar el descanso en el último ciclo, etc., si querés ser 100% exacto luego)
    int cycleTime = (_work + _rest) * _cycles;
    int setTime = cycleTime * _sets;
    int restSetTime = _restBetweenSets * (_sets > 1 ? _sets - 1 : 0);
    int totalSeconds = _prepare + setTime + restSetTime + _coolDown;

    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  int get _totalIntervals {
    return (_cycles * 2) * _sets; // Trabajo y descanso = 2 intervalos por ciclo
  }

  void _increment(String field) {
    setState(() {
      if (field == 'prepare') _prepare++;
      if (field == 'work') _work++;
      if (field == 'rest') _rest++;
      if (field == 'cycles') _cycles++;
      if (field == 'sets') _sets++;
      if (field == 'restBetweenSets') _restBetweenSets++;
      if (field == 'coolDown') _coolDown++;
    });
  }

  void _decrement(String field) {
    setState(() {
      if (field == 'prepare' && _prepare > 0) _prepare--;
      if (field == 'work' && _work > 1) _work--; // Minimo 1 seg
      if (field == 'rest' && _rest > 0) _rest--;
      if (field == 'cycles' && _cycles > 1) _cycles--; // Minimo 1 ciclo
      if (field == 'sets' && _sets > 1) _sets--; // Minimo 1 serie
      if (field == 'restBetweenSets' && _restBetweenSets > 0) _restBetweenSets--;
      if (field == 'coolDown' && _coolDown > 0) _coolDown--;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de colores basada en la captura
    const primaryColor = Color(0xFF3F51B5); // Azul índigo clásico

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Timer', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.remove_red_eye, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "$_totalTimeFormatted • $_totalIntervals intervals",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildConfigRow(
                  icon: Icons.directions_walk,
                  title: "Prepare",
                  value: _prepare,
                  field: 'prepare',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.fitness_center,
                  title: "Work",
                  subtitle: "Add description",
                  value: _work,
                  field: 'work',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.accessibility_new,
                  title: "Rest",
                  subtitle: "Add description",
                  value: _rest,
                  field: 'rest',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.sync,
                  title: "Cycles (work & rest)",
                  value: _cycles,
                  field: 'cycles',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.update,
                  title: "Sets (repeat all)",
                  value: _sets,
                  field: 'sets',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.chair_alt,
                  title: "Rest between sets",
                  value: _restBetweenSets,
                  field: 'restBetweenSets',
                  primaryColor: primaryColor,
                ),
                _buildDivider(),
                _buildConfigRow(
                  icon: Icons.weekend,
                  title: "Cool down",
                  value: _coolDown,
                  field: 'coolDown',
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
          
          // Barra inferior estilo captura
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                // Botón Menú
                Container(
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.list, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                
                // Botón START gigante
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerRunningScreen(
                          prepareSeconds: _prepare,
                          workSeconds: _work,
                          restSeconds: _rest,
                          cycles: _cycles,
                          sets: _sets,
                          restBetweenSetsSeconds: _restBetweenSets,
                          coolDownSeconds: _coolDown,
                        ),  
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    label: const Text("START", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón Agregar
                Container(
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Colors.black12);
  }

  // Componente que recrea exactamente la fila de la app
  Widget _buildConfigRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required int value,
    required String field,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Icono lateral
          Icon(icon, size: 40, color: primaryColor),
          const SizedBox(width: 16),
          
          // Contenido central (Título, Botones y Valor)
          Expanded(
            child: Column(
              children: [
                Text(title, style: TextStyle(fontSize: 18, color: primaryColor)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black26)),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón Menos (-)
                    GestureDetector(
                      onTap: () => _decrement(field),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.remove, color: Colors.white, size: 24),
                      ),
                    ),
                    
                    // Número central
                    Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 24, color: Colors.black87),
                    ),
                    
                    // Botón Más (+)
                    GestureDetector(
                      onTap: () => _increment(field),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Espacio a la derecha para balancear el diseño si tiene icono a la izquierda
          const SizedBox(width: 40), 
        ],
      ),
    );
  }
}