import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Asegúrate de importar el archivo donde definiste la clase Plan.
// Si está en plan_tab.dart, importa ese archivo. 
// Ejemplo: import 'tabs/plan_tab.dart'; 

// Si no has movido la clase Plan a su propio archivo, 
// puedes copiar la clase Plan aquí temporalmente o (mejor aún) moverla a /models/plan.dart

// 1. Modelo simple para los ejercicios (Local para esta vista)
class Exercise {
  final String name;
  final String sets;
  final String reps;
  
  Exercise({required this.name, required this.sets, required this.reps});

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise(
      name: data['name'] ?? 'Ejercicio sin nombre',
      sets: data['sets']?.toString() ?? '0',
      reps: data['reps']?.toString() ?? '0',
    );
  }
}

class PlanDetailScreen extends StatelessWidget {
  // Recibimos el plan como parámetro desde la pantalla anterior
  final dynamic plan; // Uso dynamic por si no has importado la clase Plan aún, pero deberías usar 'final Plan plan'

  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
      ),
      body: Column(
        children: [
          // --- Encabezado con información general ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.description,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoBadge(Icons.timer, '${plan.durationWeeks} Semanas'),
                    _buildInfoBadge(Icons.bar_chart, plan.level),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // --- Título de la sección de ejercicios ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: const [
                Icon(Icons.list_alt, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "Ejercicios de la Rutina",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // --- Lista de Ejercicios desde Firebase ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Asumimos que dentro del documento del plan, hay una subcolección 'exercises'
              stream: FirebaseFirestore.instance
                  .collection('plans')
                  .doc(plan.id)
                  .collection('exercises')
                  .orderBy('order', descending: false) // Opcional: si tienes un campo 'order'
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar ejercicios"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyExercisesState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final exercise = Exercise.fromFirestore(docs[index]);
                    return _buildExerciseTile(exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botón para "Empezar este plan" (Acción lógica para el alumno)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('¡Has comenzado el plan ${plan.title}!'))
            );
          },
          child: const Text("EMPEZAR PLAN", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.blue),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${exercise.sets} series x ${exercise.reps} repeticiones"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyExercisesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.running_with_errors, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "No hay ejercicios cargados en este plan.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}