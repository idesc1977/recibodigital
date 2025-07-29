import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/userdetails.dart';
import 'screens/search.dart';
import 'screens/notifications.dart';
import 'screens/chat.dart';
import 'screens/logout.dart';
import '../globals.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Handler de mensajes en segundo plano (DEBE ir en el main)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicialización necesaria si vas a usar otros servicios de Firebase aquí
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Procesamiento en segundo plano (opcional)
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registrar handler de mensajes en segundo plano ANTES de runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Captura de errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    runApp(ErrorApp(details.exceptionAsString()));
  };

  runZonedGuarded(() async {
    runApp(const LoadingApp());

    await _initializeApp();

    runApp(const MyApp());
  }, (error, stack) {
    runApp(ErrorApp(error.toString()));
  });
}

Future<void> _initializeApp() async {
  // Inicializa Firebase primero
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Luego solicita permisos de notificaciones
  await requestNotificationPermission();
  await FirebaseMessaging.instance.requestPermission();

  // Inicializar notificaciones locales
  await _initializeNotifications();

  // Configurar listeners de mensajes en foreground
  _setupMessageListeners();

  // Resetear variables globales y otras inicializaciones
  resetGlobalVariables();
  await _getDeviceToken();
  await _clearChatHistory();
}

/// App que se muestra mientras se inicializa
class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// App que se muestra cuando ocurre un error grave
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          title: const Text('🚨 Error de Inicialización'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Text(
              'Ocurrió un error al iniciar la app:\n\n$errorMessage',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

/// App principal
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

// Inicializaciones

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void _setupMessageListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformDetails,
      );
    }
  });
}

Future<void> _getDeviceToken() async {
  try {
    tokenfirebase = await FirebaseMessaging.instance.getToken();
  } catch (e) {
    // Manejo de error silencioso
  }
}

Future<void> _clearChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history");
}

Future<void> requestNotificationPermission() async {
  await Permission.notification.request();
}
