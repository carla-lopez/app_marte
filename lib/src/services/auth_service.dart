import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ACA VA TU IP: Reemplazá las X por los números que te dio ipconfig en la consola
  final String baseUrl =
      'https://discover-penknife-dagger.ngrok-free.dev'; // Ejemplo: 'http://

  // Método para Iniciar Sesión con tu servidor Python
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      // Le mandamos los datos al puerto 8000
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Si el servidor responde bien (código 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return null; // Retornar null significa que todo salió perfecto
        } else {
          return data['mensaje'] ?? 'Error de credenciales';
        }
      } else {
        return 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      // Este error salta si la compu está apagada o el celular no está en el mismo Wi-Fi
      return 'No se pudo conectar con el servidor. Revisá tu conexión.';
    }
  }

  // Método para Cerrar Sesión (por ahora lo dejamos vacío hasta que usemos tokens)
  Future<void> logout() async {
    // Lógica futura de cierre de sesión
  }
}
