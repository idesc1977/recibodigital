import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart';
import 'userdetails.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoading2 = false;
  String? fotoUrl;
  String? emailUser;
  String? tokenUser;

  @override
  void initState() {
    super.initState();
    _loadFotoUrl();
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
      final Uri url =
          Uri.parse('https://www.emicardigital.com.ar/recibodigital/api/login');

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
          cuil = responseData['CUIL'].toString();
          legajo = responseData['Legajo'].toString();
          saveUserData(dni!, email!, token!);
          _showMessage('Bienvenido $nombre $apellido');
          _registraTopic(propietario!);

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
      final Uri url = Uri.parse(
          'https://www.emicardigital.com.ar/recibodigital/api/forgetpassword');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Token': tokenUser,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        _showMessage(responseData['Respuesta']);
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _registraTopic(String topic) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    try {
      await firebaseMessaging.subscribeToTopic(topic);
    } catch (_) {}
  }

  Future<void> saveUserData(String dni, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'fotoURL', "https://www.emicardigital.com.ar/fotos/$dni.jpg");
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }

  Future<void> _loadFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fotoUrl = prefs.getString('fotoURL') ?? '';
      emailUser = prefs.getString('email') ?? '';
      tokenUser = prefs.getString('token') ?? '';
      _usernameController.text = emailUser!;
      if (tokenfirebase == '') {
        _getDeviceToken();
      }
    });
  }

  Future<void> _getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        // Si no está disponible, espera unos segundos y reintenta
        if (apnsToken == null) {
          await Future<void>.delayed(const Duration(seconds: 3));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
      }
      tokenfirebase = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      // Manejo de error silencioso
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de Sesión",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          try {
            return _buildLoginUI(context);
          } catch (error, stackTrace) {
            return _buildErrorScreen(error, stackTrace);
          }
        },
      ),
    );
  }

  Widget _buildLoginUI(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'images/logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                    ? NetworkImage(fotoUrl!)
                    : const AssetImage('images/login.png') as ImageProvider,
                backgroundColor: const Color.fromARGB(255, 250, 249, 249),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Iniciar Sesión'),
                  ),
            const SizedBox(height: 50),
            const Divider(thickness: 2, color: Colors.grey),
            const SizedBox(height: 10),
            _isLoading2
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _forgetPassword(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Olvidé mi Password'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error, StackTrace stackTrace) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            const Text(
              "Ha ocurrido un error inesperado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "$error",
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}
