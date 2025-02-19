import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu.dart';
import '../globals.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  void _logoutAndExit() {
    // Aquí puedes agregar tu lógica de deslogueo
    resetGlobalVariables(); // Limpia las variables globales
    // Cerrar la aplicación
    SystemNavigator.pop(); // Cierra la aplicación
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Salir", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading:
            false, // Elimina la flecha de regreso // Color de fondo del AppBar
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta los elementos al centro
          children: [
            // Logo de la empresa
            Image.asset(
              'images/logo.png',
              height: 100,
              fit: BoxFit.contain, // Ajusta el tamaño de la imagen
            ),
            SizedBox(height: 20), // Espaciado entre logo y botón
            // Botón de cerrar sesión
            ElevatedButton(
              onPressed: () {
                _logoutAndExit();
              },
              child: Text("Cerrar sesión y salir"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
