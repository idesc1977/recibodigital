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
      _tokenStatus = '⏳ Solicitando permisos de notificación...';
    });

    try {
      // 1. Solicitar permisos al usuario
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // 2. Evaluar el estado de los permisos
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        setState(() {
          _tokenStatus = '🚫 Permisos de notificación denegados.';
        });
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        setState(() {
          _tokenStatus = '❗ El usuario aún no decidió sobre los permisos.';
        });
        return;
      }

      setState(() {
        _tokenStatus = '✅ Permisos concedidos.\n⏳ Obteniendo tokens...';
      });

      // 3. Obtener token APNs en iOS
      String? apnsToken;
      if (Platform.isIOS) {
        try {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            setState(() {
              _tokenStatus = '''
        ❗ Token APNs no disponible todavía.
        🔁 Intenta nuevamente en unos segundos.
        ''';
            });
            return;
          }
        } catch (e) {
          setState(() {
            _tokenStatus = '''
        ❌ Error al obtener el token APNs.

        💬 Detalle técnico:
        $e
        ''';
          });
          return;
        }
      }

      // 4. Obtener token FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        setState(() {
          _tokenStatus = '''
⚠️ No se pudo obtener el token FCM.

📱 APNs Token: ${apnsToken ?? 'No disponible'}
''';
        });
        return;
      }

      // 5. Mostrar tokens en pantalla
      setState(() {
        _tokenStatus = '''
✅ Tokens obtenidos correctamente:

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
                  label: const Text("Solicitar permisos y token FCM"),
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
