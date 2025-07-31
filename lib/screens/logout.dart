import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

import 'menu.dart';
import '../globals.dart';
import 'login.dart'; // Asegúrate de tener esta import para navegar al login

class Logout extends StatelessWidget {
  const Logout({super.key});

  Future<void> _logoutAndExit(BuildContext context) async {
    // 1) Lógica de deslogueo y limpieza de estado
    resetGlobalVariables(); // tu función global

    // 2) Limpia almacenamiento local si aplica
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.clear(); // o remove(...) lo que uses

    // 3) Revoca token FCM (opcional pero recomendado)
    //try {
    //  await FirebaseMessaging.instance.deleteToken();
    // Si usas topics:
    // await FirebaseMessaging.instance.unsubscribeFromTopic('mi_topic');
    //} catch (_) {
    // evita crash; log si quieres
    //}

    // 4) Navega a la pantalla de Login y limpia el stack
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    // 5) En Android, además, cerrar la app si realmente querés salir
    if (Platform.isAndroid) {
      // Dar un pequeño delay para permitir renderizar el Login si fuese necesario
      await Future<void>.delayed(const Duration(milliseconds: 100));
      SystemNavigator.pop();
    }

    // En iOS, Apple no permite salir programáticamente: la app queda en la pantalla de Login.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salir", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Center(
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
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
