import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
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

/// Inicializaciones globales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Punto de entrada de la app con manejo de errores global
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    runApp(ErrorApp(details.exceptionAsString()));
  };

  runZonedGuarded(() async {
    runApp(const AppEntryPoint());
  }, (error, stackTrace) {
    runApp(ErrorApp(error.toString()));
  });
}

/// Inicializa las notificaciones locales
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// Configura los listeners de mensajes de Firebase Messaging
void _setupMessageListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

/// Maneja mensajes recibidos en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    // Procesar notificación si es necesario
  }
  if (message.data.isNotEmpty) {
    // Procesar datos adicionales
  }
}

/// Borra historial de chat
Future<void> _clearChatHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history");
}

/// Solicita permiso de notificaciones (iOS)
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.request().isGranted) {
    // Permiso concedido
  } else {
    // Permiso denegado
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

/// App que muestra errores en pantalla
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp(this.errorMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(title: const Text('🚨 Error de Inicialización')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Text(
              'Ocurrió un error al iniciar la aplicación:\n\n$errorMessage',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

/// AppEntryPoint: espera a que Firebase y el token estén listos
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Pedir permisos
      await requestNotificationPermission();

      // Inicializar Firebase y permisos
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission();

      // Obtener token FCM
      tokenfirebase = await FirebaseMessaging.instance.getToken();

      // Inicializaciones extra
      await _initializeNotifications();
      _setupMessageListeners();
      resetGlobalVariables();
      await _clearChatHistory();

      setState(() {
        _ready = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorApp(_error!);
    }

    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return const MyApp(); // <- App principal cuando todo está listo
  }
}
