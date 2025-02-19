import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para manejar JSON
import '../globals.dart'; // Importar las variables globales
import 'menu.dart';
import 'userdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  bool _isLoading = false; // Indicador de carga
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    _loadFotoUrl(); // Cargar la URL desde SharedPreferences
  }

  Future<void> _changePassword(BuildContext context) async {
    final String password = _passwordController.text;
    final String password2 = _passwordController2.text;

    if (password.isEmpty || password2.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // URL de la API
      final Uri url = Uri.parse(
          'https://www.emicardigital.com.ar/recibodigital/api/changepassword');

      // Solicitud POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Token': token,
          'New_Password': password,
          'New_Password_Confirm': password2
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Success'] == true) {
          if (responseData['Procesado'] == true) {
            _showMessage(responseData['Respuesta']);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetails(),
                ),
              );
            }
          } else {
            _showMessage(responseData['Respuesta']);
          }
        } else {
          _showMessage(responseData['Respuesta']);
        }
      } else {
        _showMessage('Token inválido.');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //Obtiene Datos
  Future<void> _loadFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fotoUrl = prefs.getString('fotoURL') ?? ''; // Obtener fotoURL o vacío
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar Password", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading:
            true, // Muestra la flecha de regreso // Color de fondo del AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center, // Centrar horizontalmente
                child: Image.asset(
                  'images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                  height: 15.0), // Espacio entre el label y el ListView
              // Imagen circular
              Center(
                child: CircleAvatar(
                  radius: 50, // Tamaño del avatar
                  backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                      ? NetworkImage(fotoUrl!) // Si tiene URL, cargarla
                      : AssetImage('images/login.png')
                          as ImageProvider, // Si no, cargar el asset
                  backgroundColor:
                      Colors.grey[300], // Color de fondo si la imagen no carga
                ),
              ),
              SizedBox(height: 20), // Espaciado
              Center(
                child: RichText(
                  text: TextSpan(
                    text: nombre, // valorLabel en estilo normal
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal, // Mantiene el peso normal
                      color: Colors.lightBlue, // Color azul claro para el valor
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: apellido, //
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal, // Mantiene el peso normal
                      color: Colors.lightBlue, // Color azul claro para el valor
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Oculta el texto para contraseñas
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController2,
                decoration: InputDecoration(
                  labelText: 'Confirme Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Oculta el texto para contraseñas
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24, // Tamaño del indicador
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                  : Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _changePassword(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Color de fondo rojo
                          foregroundColor:
                              Colors.white, // Color del texto blanco
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Bordes redondeados opcionales
                          ),
                        ),
                        child: Text('Cambiar Password'),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
