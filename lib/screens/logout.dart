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
      _tokenStatus = '⏳ Solicitando token FCM...';
    });

    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          setState(() {
            _tokenStatus = '✅ Token FCM obtenido:\n$token';
          });
        } else {
          setState(() {
            _tokenStatus =
                '⚠️ Token FCM nulo. Revisa configuración de APNs y permisos.';
          });
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        setState(() {
          _tokenStatus = '🚫 Permisos de notificación denegados.';
        });
      } else {
        setState(() {
          _tokenStatus = '❓ Estado de permisos desconocido.';
        });
      }
    } catch (e) {
      setState(() {
        _tokenStatus = '❌ Error al obtener el token:\n$e';
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
                Text(
                  _tokenStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
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
