import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para manejar JSON
import '../globals.dart';
import 'userdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Indicador de carga
  bool _isLoading2 = false; // Indicador de carga
  String? fotoUrl;
  String? emailUser;
  String? tokenUser;

  @override
  void initState() {
    super.initState();
    _loadFotoUrl(); // Cargar la URL desde SharedPreferences
  }

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String? tokenFCM = tokenfirebase;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // URL de la API
      final Uri url =
          Uri.parse('https://www.emicardigital.com.ar/recibodigital/api/login');

      // Solicitud POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Username': username,
          'Password': password,
          'Token_Firebase': tokenFCM
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Success'] == true) {
          nombre = responseData['Nombre'];
          apellido = responseData['Apellido'];
          dni = responseData['DNI'].toString();
          token = responseData['Token'].toString();
          propietario = responseData['Propietario'].toString();
          fechanacimiento =
              formatFechaRecibo(responseData['Fecha_Nacimiento'].toString());
          direccion = responseData['Direccion'].toString();
          cp = responseData['CP'].toString();
          telefono = responseData['Telefono'].toString();
          email = responseData['Email'].toString();
          sexo = responseData['Sexo'].toString();
          empresa = responseData['Empresa'].toString();
          saveUserData(dni!, email!, token!);
          _showMessage('Bienvenido $nombre $apellido');

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetails(),
              ),
            );
          }
        } else {
          _showMessage('Usuario o contraseña incorrectos.');
        }
      } else {
        _showMessage('Usuario o contraseña incorrectos.');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forgetPassword(BuildContext context) async {
    final String username = _usernameController.text;

    if (username.isEmpty) {
      _showMessage('Ingresa el usuario por favor.');
      return;
    }

    setState(() {
      _isLoading2 = true;
    });

    try {
      // URL de la API
      final Uri url = Uri.parse(
          'https://www.emicardigital.com.ar/recibodigital/api/forgetpassword');

      // Solicitud POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Token': tokenUser,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Success'] == true) {
          if (responseData['Procesado'] == true) {
            _showMessage(responseData['Respuesta']);
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
        _isLoading2 = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Guardar Datos
  Future<void> saveUserData(String dni, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'fotoURL', "https://www.emicardigital.com.ar/fotos/$dni.jpg");
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }

  //Obtiene Datos
  Future<void> _loadFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fotoUrl = prefs.getString('fotoURL') ?? ''; // Obtener fotoURL o vacío
      emailUser = prefs.getString('email') ?? ''; // Obtener el usuario o email
      tokenUser = prefs.getString('token') ??
          ''; // Obtener el token (GUID) del dispositivo
      _usernameController.text = emailUser!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inicio de Sesión", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Elimina la flecha de regreso
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ajusta al ancho del contenedor
            children: [
              // Logo de la empresa
              Image.asset(
                'images/logo.png',
                height: 100,
                fit: BoxFit.contain, // Ajusta el tamaño de la imagen
              ),
              SizedBox(height: 20), // Espaciado entre logo y botón
              // Imagen circular
              Center(
                child: CircleAvatar(
                  radius: 50, // Tamaño del avatar
                  backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                      ? NetworkImage(fotoUrl!) // Si tiene URL, cargarla
                      : AssetImage('images/login.png')
                          as ImageProvider, // Si no, cargar el asset
                  backgroundColor: const Color.fromARGB(255, 250, 249,
                      249), // Color de fondo si la imagen no carga
                ),
              ),
              SizedBox(height: 20), // Espaciado
              // Espacio entre la imagen y los campos de texto
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
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
                  : ElevatedButton(
                      onPressed: () {
                        _login(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.lightBlue, // Color de fondo rojo
                        foregroundColor: Colors.white, // Color del texto blanco
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Bordes redondeados opcionales
                        ),
                      ),
                      child: Text('Iniciar Sesión'),
                    ),
              SizedBox(height: 50),
              // Línea separadora horizontal
              Divider(
                thickness: 2, // Grosor de la línea
                color: Colors.grey, // Color de la línea
                indent: 5, // Margen izquierdo
                endIndent: 5, // Margen derecho
              ),
              SizedBox(height: 10),
              _isLoading2
                  ? Center(
                      child: SizedBox(
                        width: 24, // Tamaño del indicador
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _forgetPassword(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Color de fondo rojo
                        foregroundColor: Colors.white, // Color del texto blanco
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Bordes redondeados opcionales
                        ),
                      ),
                      child: const Text('Olvidé mi Password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
