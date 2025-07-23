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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Pedir permisos en tiempo de ejecución
  await requestNotificationPermission();

  //Inicializar Firebase
  await Firebase.initializeApp();

  // 🔐 Solicitar permiso de notificaciones desde Firebase (clave en iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Inicializar notificaciones locales y Firebase Messaging
  await _initializeNotifications();

  // Configurar manejadores de mensajes
  _setupMessageListeners();

  // Inicializar variables globales
  resetGlobalVariables();

  // Obtener token del dispositivo
  await _getDeviceToken();

  // 🔥 Borra historial de chat antes de iniciar la aplicación
  await _clearChatHistory();

  runApp(const MyApp());
}

/// Inicializaciones globales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  // Listener para mensajes en foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //print('Mensaje recibido en foreground: ${message.messageId}');
    if (message.notification != null) {
      //print('Título: ${message.notification?.title}');
      //print('Cuerpo: ${message.notification?.body}');

      // Mostrar notificación local
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channel_id', // ID del canal
        'channel_name', // Nombre del canal
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

  // Listener para mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

/// Maneja mensajes recibidos en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //print('Mensaje recibido en background: ${message.messageId}');
  if (message.notification != null) {
    //print('Título: ${message.notification?.title}');
    //print('Cuerpo: ${message.notification?.body}');
  }
  if (message.data.isNotEmpty) {
    //print('Datos: ${message.data}');
  }
}

/// Obtiene el token del dispositivo para Firebase Messaging
Future<void> _getDeviceToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  try {
    String? token = await messaging.getToken();
    tokenfirebase = token;
    //print("Token del dispositivo: $token");
  } catch (e) {
    //print("Error al obtener el token del dispositivo: $e");
  }
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
