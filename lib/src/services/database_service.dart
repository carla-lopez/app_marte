import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MÉTODOS PARA EL ALUMNO

  // 1. Obtener la rutina (CORREGIDO: Busca 'Rutinas' con R mayúscula)
  Stream<DocumentSnapshot> getWeeklyRoutine(String uid, String semanaId) {
    // Imprimimos en la consola para depurar
    print(
      "🔥 INTENTANDO CONECTAR A: /Rutinas/j8HyOkeUBPPs7xbPlAbelLMCSvp2/semanas/semana_1",
    );

    return _db
        .collection(
          'Rutinas',
        ) // <--- AQUÍ ESTABA EL PROBLEMA (Antes decía 'rutinas')
        .doc('j8HyOkeUBPPs7xbPlAbelLMCSvp2')
        .collection('semanas')
        .doc('semana_1')
        .snapshots();
  }

  // 2. Guardar cambios (CORREGIDO: Busca 'Rutinas' con R mayúscula)
  // 2. Guardar el peso o nota que escribió el alumno (LÓGICA MEJORADA)
  // 2. Guardar el peso o nota que escribió el alumno (VERSIÓN NULL-SAFE)
  Future<void> updateExerciseData({
    required String uid,
    required String semanaId,
    required int diaIndex,
    required int ejercicioIndex,
    required int serieIndex,
    required String campo,
    required dynamic valor,
  }) async {
    // 1. Referencia al documento
    DocumentReference docRef = _db
        .collection('Rutinas')
        .doc(uid)
        .collection('semanas')
        .doc(semanaId);

    try {
      // 2. Obtenemos el snapshot actual
      DocumentSnapshot snapshot = await docRef.get();

      // Si el documento NO existe, salimos sin error (ya no tiramos la excepción)
      if (!snapshot.exists || snapshot.data() == null) return;

      // 3. Extracción y Conversión a LISTAS MUTABLES (Defensa contra el 'Null')
      Map<String, dynamic> data = Map.from(
        snapshot.data() as Map,
      ); //Convertimos el paquete a Map mutable

      // Asegurando que 'dias' es una lista mutable,forzando la conversion segura
      List<dynamic> dias = (data['dias'] as List? ?? [])
          .map((d) => Map<String, dynamic>.from(d))
          .toList();

      // Navegación segura
      if (dias.length <= diaIndex) return;
      Map<String, dynamic> diaTarget = dias[diaIndex];

      // Accediendo a 'ejercicios' de forma segura
      List<dynamic> ejercicios = List.from(
        diaTarget['ejercicios'] ?? [],
      ).map((e) => Map<String, dynamic>.from(e)).toList();
      if (ejercicios.length <= ejercicioIndex) return;
      Map<String, dynamic> ejercicioTarget = ejercicios[ejercicioIndex];

      // Accediendo a 'series' de forma segura
      List<dynamic> series = List.from(
        ejercicioTarget['series'] ?? [],
      ).map((s) => Map<String, dynamic>.from(s)).toList();
      if (series.length <= serieIndex) return;
      Map<String, dynamic> serieTarget = series[serieIndex];

      // 4. Modificamos el valor
      serieTarget[campo] = valor;

      // 5. Reconstrucción y actualización
      series[serieIndex] = serieTarget;
      ejercicioTarget['series'] = series;
      ejercicios[ejercicioIndex] = ejercicioTarget;
      diaTarget['ejercicios'] = ejercicios;
      dias[diaIndex] = diaTarget;

      await docRef.update({'dias': dias});
      print("✅ ESCRITURA EXITOSA en Firestore.");
    } on FirebaseException catch (e) {
      print("❌ FIREBASE EXCEPTION: ${e.code}. Verifique reglas/conexión.");
    } catch (e) {
      print("❌ ERROR INESPERADO: $e");
    }
  }
}
