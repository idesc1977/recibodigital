import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';

class ChatService {
  // URL de la API
  static const String apiUrl =
      "https://www.emicardigital.com.ar/recibodigital/api/chatbot";

  static Future<String> sendMessage(String mensaje) async {
    try {
      // Solicitud POST
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Id_Conversacion": idconversacion,
          "Token": token,
          "Mensaje": mensaje
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['Success'] == true) {
          idconversacion = responseData['Id_Conversacion'];
          return responseData["Respuesta"];
        } else {
          return "Error en la API del Chat";
        }
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error de conexión";
    }
  }
}
