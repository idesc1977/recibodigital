import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chatservice.dart';
import 'menu.dart';
import '../globals.dart'; // Importar las variables globales

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Cargar historial al iniciar la pantalla
  }

  /// 📌 Cargar mensajes guardados en SharedPreferences
  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedMessages = prefs.getString("chat_history");

    if (storedMessages != null) {
      List<dynamic> decodedList = jsonDecode(storedMessages);

      // 🔥 Conversión a List<Map<String, String>>
      setState(() {
        messages =
            decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
    }

    // 📌 Si no hay mensajes previos, mostrar mensaje de bienvenida
    if (messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  /// 📌 Agregar mensaje de bienvenida del bot
  void _addWelcomeMessage() {
    setState(() {
      messages.add({
        "role": "bot",
        "text":
            "¡Hola! Soy tu asistente virtual en Ética y Conducta de la Empresa. ¿En qué puedo ayudarte hoy?"
      });
    });
    _saveMessages();
  }

  /// 📌 Guardar mensajes en SharedPreferences
  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("chat_history", jsonEncode(messages));
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text;
      setState(() {
        messages.add({"role": "user", "text": userMessage});
      });
      _controller.clear();
      _saveMessages(); // Guardar después de agregar mensaje del usuario

      String botResponse = await ChatService.sendMessage(userMessage);
      setState(() {
        messages.add({"role": "bot", "text": botResponse});
      });
      _saveMessages(); // Guardar después de recibir respuesta del bot
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ChatBot", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("chat_history");
                setState(() {
                  messages.clear();
                });
                idconversacion = 0;
              },
            ),
          ], // Elimina la flecha de regreso // Color de fondo del AppBar
        ),
        body: Column(
          children: [
            const SizedBox(height: 15.0),
            Align(
              alignment: Alignment.center, // Centrar horizontalmente
              child: Image.asset(
                'images/logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 1.0), // Espacio entre el label y el ListView
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]["role"] == "user";

                  return Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser) // Avatar del bot (izquierda)
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.android, color: Colors.black),
                        ),
                      SizedBox(width: 10), // Espacio entre avatar y mensaje
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft:
                                isUser ? Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isUser ? Radius.zero : Radius.circular(12),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Text(
                          messages[index]["text"]!,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black),
                        ),
                      ),
                      SizedBox(width: 10), // Espacio entre mensaje y avatar
                      if (isUser) // Avatar del usuario (derecha)
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3));
  }
}
