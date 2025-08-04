import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'menu.dart';
import '../globals.dart';
import 'login.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  String _tokenStatus = 'Presiona el botón para solicitar el token FCM.';

  Future<void> _logoutAndExit(BuildContext context) async {
    resetGlobalVariables();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    if (Platform.isAndroid) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      SystemNavigator.pop();
    }
  }

  Future<void> _solicitarTokenFCM() async {
    setState(() {
      _tokenStatus = '⏳ Solicitando tokens...';
    });

    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        setState(() {
          _tokenStatus =
              '🚫 Permisos de notificación denegados por el usuario.';
        });
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        setState(() {
          _tokenStatus = '❗ Permisos de notificación no solicitados.';
        });
        return;
      }

      // 1. Obtener APNs token (iOS)
      String? apnsToken;
      if (Platform.isIOS) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          setState(() {
            _tokenStatus = '''
❗ El token APNs aún no está disponible.
Esto es común justo después de iniciar la app por primera vez.

🔁 Por favor, vuelve a intentarlo en unos segundos.
''';
          });
          return;
        }
      }

      // 2. Obtener token FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        setState(() {
          _tokenStatus = '''
⚠️ Token FCM nulo. Posibles causas:
- APNs token no válido
- Error de configuración en Firebase
- Error en capabilities (Push Notifications)

📱 APNs Token: ${apnsToken ?? 'No disponible'}
''';
        });
        return;
      }

      // 3. Mostrar ambos tokens
      setState(() {
        _tokenStatus = '''
✅ Tokens obtenidos exitosamente:

📩 FCM Token:
$fcmToken

📱 APNs Token:
${apnsToken ?? 'No aplica (Android)'}
''';
      });
    } catch (e) {
      setState(() {
        _tokenStatus = '❌ Error al obtener los tokens:\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salir", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _logoutAndExit(context),
                  child: const Text("Cerrar sesión y salir"),
                ),
                const SizedBox(height: 30),
                const Divider(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active),
                  label: const Text("Solicitar token FCM"),
                  onPressed: _solicitarTokenFCM,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    _tokenStatus,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
