import 'package:flutter/material.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // EL PIZARRÓN DEL WOD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50), // Color pizarra oscuro
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.brown.shade600,
              width: 8,
            ), // Borde simulando madera
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "WOD DEL DÍA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Divider(color: Colors.white54, thickness: 2),
              SizedBox(height: 10),
              // Acá va el texto del entrenamiento. Después podés sumarle una fuente tipo tiza (Chalk)
              Text(
                "AMRAP 15 MIN:\n\n• 10 Burpees\n• 15 Kettlebell Swings\n• 20 Box Jumps",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "¡A dejarlo todo!",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // SECCIÓN DE INFORMACIÓN Y NOVEDADES
        const Text(
          "NOVEDADES DEL BOX",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        // Tarjeta de Info 1
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.warning_amber_rounded, color: Colors.white),
            ),
            title: const Text("Feriado del Lunes"),
            subtitle: const Text(
              "El box permanecerá cerrado. Tienen la rutina en casa cargada en la app.",
            ),
            onTap: () {},
          ),
        ),

        // Tarjeta de Info 2
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.event, color: Colors.white),
            ),
            title: const Text("Competencia Interna"),
            subtitle: const Text(
              "Abiertas las inscripciones para la competencia de duplas de este mes.",
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
