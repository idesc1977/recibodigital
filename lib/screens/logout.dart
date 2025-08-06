import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart' show RestartWidget;
import '../globals.dart';
import 'menu.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  Future<void> _logoutAndExit(BuildContext context) async {
    // 1. Limpia variables y estado global
    resetGlobalVariables();

    if (Platform.isIOS) {
      // --- iOS: reinicio total del árbol de widgets ---
      RestartWidget.restartApp(context);
    } else if (Platform.isAndroid) {
      // --- Android: cerrar la app completamente ---
      await Future<void>.delayed(const Duration(milliseconds: 100));
      SystemNavigator.pop();
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
