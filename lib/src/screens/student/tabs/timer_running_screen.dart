import 'dart:async';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Definimos todas las fases posibles del nuevo timer
enum TimerPhase { prepare, work, rest, restBetweenSets, coolDown, finished }

class TimerRunningScreen extends StatefulWidget {
  final int prepareSeconds;
  final int workSeconds;
  final int restSeconds;
  final int cycles;
  final int sets;
  final int restBetweenSetsSeconds;
  final int coolDownSeconds;

  const TimerRunningScreen({
    super.key,
    required this.prepareSeconds,
    required this.workSeconds,
    required this.restSeconds,
    required this.cycles,
    required this.sets,
    required this.restBetweenSetsSeconds,
    required this.coolDownSeconds,
  });

  @override
  State<TimerRunningScreen> createState() => _TimerRunningScreenState();
}

class _TimerRunningScreenState extends State<TimerRunningScreen> {
  late Timer _timer;
  final AudioPlayer _player = AudioPlayer(); 

  // Generador aleatorio y listas de sonidos
  final Random _random = Random();
  final List<String> _halfwaySounds = ['halfway.mp3', 'halfway2.mp3', 'halfway3.mp3']; 
  final List<String> _finishSounds = ['finish1.mp3', 'finish2.mp3', 'finish3.mp3'];

  // Estados
  bool _isRunning = false;
  TimerPhase _currentPhase = TimerPhase.prepare;
  
  // Contadores
  int _currentCycle = 1;
  int _currentSet = 1;
  int _secondsRemaining = 0;
  
  // Para controlar el sonido de mitad de tiempo
  bool _halfwaySoundPlayed = false;

  @override
  void initState() {
    super.initState();
    _player.setSource(AssetSource('sounds/beep.mp3'));

    // Configuración inicial
    if (widget.prepareSeconds > 0) {
      _currentPhase = TimerPhase.prepare;
      _secondsRemaining = widget.prepareSeconds;
    } else {
      // Si el usuario puso 0 en prep, saltamos directo al trabajo
      _startWorkPhase();
    }

    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      setState(() {
        _handleTick();
      });
    });
  }

  void _handleTick() {
    // 1. Chequeo de "Halfway" solo durante el Trabajo
    if (_currentPhase == TimerPhase.work && !_halfwaySoundPlayed && widget.workSeconds > 0) {
      // Calculamos la mitad (truncada)
      int halfwayPoint = widget.workSeconds ~/ 2;
      
      // Si llegamos a la mitad, disparamos el sonido
      if (_secondsRemaining == halfwayPoint) {
        _playRandomSound(_halfwaySounds);
        _halfwaySoundPlayed = true;
      }
    }

    // 2. Cuenta regresiva final (5, 4, 3, 2, 1) para cualquier fase activa
    if (_secondsRemaining <= 5 && _secondsRemaining > 0) {
      _playSound('beep.mp3');
    }

    // 3. Decrementar o cambiar de fase
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
    } else {
      _handlePhaseChange();
    }
  }

  // LA MÁQUINA DE ESTADOS: Decide qué fase sigue
  void _handlePhaseChange() {
    switch (_currentPhase) {
      case TimerPhase.prepare:
        _startWorkPhase();
        break;
        
      case TimerPhase.work:
        // Si no terminamos los ciclos de esta serie
        if (_currentCycle < widget.cycles) {
          if (widget.restSeconds > 0) {
            _setPhase(TimerPhase.rest, widget.restSeconds, 'rest.mp3');
          } else {
            // Si no hay descanso, pasa al siguiente ciclo directo
            _currentCycle++;
            _startWorkPhase();
          }
        } 
        // Si terminamos los ciclos, vemos si hay más series
        else {
          if (_currentSet < widget.sets) {
            if (widget.restBetweenSetsSeconds > 0) {
              _setPhase(TimerPhase.restBetweenSets, widget.restBetweenSetsSeconds, 'rest.mp3');
            } else {
              _currentSet++;
              _currentCycle = 1;
              _startWorkPhase();
            }
          } 
          // Si terminamos todas las series, vamos al enfriamiento o fin
          else {
            if (widget.coolDownSeconds > 0) {
              _setPhase(TimerPhase.coolDown, widget.coolDownSeconds, 'rest.mp3'); // Podés crear un 'cooldown.mp3'
            } else {
              _finishWorkout();
            }
          }
        }
        break;

      case TimerPhase.rest:
        _currentCycle++;
        _startWorkPhase();
        break;

      case TimerPhase.restBetweenSets:
        _currentSet++;
        _currentCycle = 1;
        _startWorkPhase();
        break;

      case TimerPhase.coolDown:
        _finishWorkout();
        break;

      case TimerPhase.finished:
        break;
    }
  }

  void _startWorkPhase() {
    _setPhase(TimerPhase.work, widget.workSeconds, 'go.mp3');
    _halfwaySoundPlayed = false; // Reseteamos el flag de la mitad
  }

  void _setPhase(TimerPhase newPhase, int seconds, String soundFile) {
    _currentPhase = newPhase;
    _secondsRemaining = seconds;
    _playSound(soundFile);
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint("Error audio: $e");
    }
  }

  void _playRandomSound(List<String> soundList) {
    if (soundList.isEmpty) return;
    int randomIndex = _random.nextInt(soundList.length);
    String selectedSound = soundList[randomIndex];
    _playSound(selectedSound);
  }

  void _finishWorkout() {
    _timer.cancel();
    _currentPhase = TimerPhase.finished;
    _playRandomSound(_finishSounds);

    setState(() {
      _isRunning = false;
      _secondsRemaining = 0;
    });
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    _player.dispose();
    super.dispose();
  }

  // --- UI Helpers para colores y textos dinámicos ---
  Color _getBackgroundColor() {
    switch (_currentPhase) {
      case TimerPhase.prepare: return Colors.amber[800]!;
      case TimerPhase.work: return Colors.green[600]!;
      case TimerPhase.rest: return Colors.red[600]!;
      case TimerPhase.restBetweenSets: return Colors.purple[600]!; // Diferenciamos el descanso largo
      case TimerPhase.coolDown: return Colors.lightBlue[400]!;
      case TimerPhase.finished: return Colors.indigo[800]!;
    }
  }

  String _getStatusText() {
    switch (_currentPhase) {
      case TimerPhase.prepare: return "PREPARATE";
      case TimerPhase.work: return "TRABAJO";
      case TimerPhase.rest: return "DESCANSÁ";
      case TimerPhase.restBetweenSets: return "DESCANSO LARGO";
      case TimerPhase.coolDown: return "ENFRIAMIENTO";
      case TimerPhase.finished: return "¡TERMINADO!";
    }
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "TABATA TIMER",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicadores de Ciclos y Series (Ocultos en Preparación y Fin)
          if (_currentPhase != TimerPhase.prepare && _currentPhase != TimerPhase.finished)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("CICLO", style: TextStyle(color: Colors.white54, fontSize: 16)),
                    Text("$_currentCycle / ${widget.cycles}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text("SERIE", style: TextStyle(color: Colors.white54, fontSize: 16)),
                    Text("$_currentSet / ${widget.sets}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 40),

          // Cronómetro gigante
          Text(
            _formatTime(_secondsRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 120,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          // Texto de estado (TRABAJO, DESCANSÁ, etc.)
          Text(
            _getStatusText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),

          const Spacer(),

          // Botones inferiores de control
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPhase != TimerPhase.finished)
                  FloatingActionButton(
                    heroTag: "btn_pause",
                    backgroundColor: Colors.white,
                    onPressed: _togglePause,
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: _getBackgroundColor(),
                      size: 32,
                    ),
                  ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "btn_stop",
                  backgroundColor: Colors.white,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.stop, color: Colors.red, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}