import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/userdetails.dart';
import 'screens/search.dart';
import 'screens/notifications.dart';
import 'screens/chat.dart';
import 'screens/logout.dart';
import '../globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Pedir permisos en tiempo de ejecución
  await requestNotificationPermission();

  // Inicializar variables globales
  resetGlobalVariables();

  // 🔥 Borra historial de chat antes de iniciar la aplicación
  await _clearChatHistory();

  runApp(const MyApp());
}

Future<void> _clearChatHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history"); // 🔥 Borra el historial del chat
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.request().isGranted) {
    //print("✅ Permiso de notificación concedido");
  } else {
    //print("❌ Permiso de notificación denegado");
  }
}

/// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recibo Digital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        '/userdetails': (context) => const UserDetails(),
        '/search': (context) => const Search(),
        '/notifications': (context) => const Notifications(),
        '/chat': (context) => const Chat(),
        '/logout': (context) => const Logout(),
      },
    );
  }
}
