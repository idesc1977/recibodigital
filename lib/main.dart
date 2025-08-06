// main.dart
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Usado SOLO en Android
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

/// 👇 Handler de mensajes en segundo plano (DEBE ir en el main)
@pragma('vm:entry-point') // Necesario para iOS en release
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Si vas a usar otros servicios de Firebase aquí, inicializa.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Procesamiento en segundo plano (opcional)
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registrar handler de mensajes en segundo plano ANTES de runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Captura global de errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    runApp(ErrorApp(details.exceptionAsString()));
  };

  runZonedGuarded(() async {
    runApp(const LoadingApp());

    await initializeApp();

    runApp(const MyApp());
  }, (error, stack) {
    runApp(ErrorApp(error.toString()));
  });
}

Future<void> initializeApp() async {
  // 1) Inicializa Firebase primero
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2) Inicializa notificaciones locales (iOS + Android)
  await _initializeLocalNotifications();

  // 3) Pide permisos de notificaciones
  //    iOS: solo Firebase (NO permission_handler)
  //    Android: también usamos permission_handler para Android 13+
  await _requestNotificationPermissions();

  // 4) Define cómo se presentan notificaciones en foreground (iOS)
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 5) Configurar listeners de mensajes en foreground
  _setupMessageListeners();

  // 6) Resetear variables globales y otras inicializaciones
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

// ==========================
// Inicializaciones / Helpers
// ==========================

Future<void> _initializeLocalNotifications() async {
  // Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS (Darwin)
  final DarwinInitializationSettings initializationSettingsDarwin =
      const DarwinInitializationSettings(
    // Ponemos false porque pedimos permisos explícitamente nosotros
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    // Si necesitas acciones/categorías, puedes definirlas aquí
  );

  // Inicialización conjunta
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin, // 👈 Esto evita el error en iOS
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Manejo del tap en notificaciones (Android/iOS modernos)
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // final payload = response.payload; // Úsalo si envías payloads
    },
  );
}

Future<void> _requestNotificationPermissions() async {
  // iOS: solo Firebase (no permission_handler)
  // Android: podemos pedir también via permission_handler para Android 13+
  if (Platform.isAndroid) {
    // En Android 13+ se requiere POST_NOTIFICATIONS en tiempo de ejecución
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // Pide permisos con Firebase (iOS/Android)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

void _setupMessageListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      // Android
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );

      // iOS (Darwin)
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
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
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      // Si no está disponible, espera unos segundos y reintenta
      if (apnsToken == null) {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
    }
    tokenfirebase = await FirebaseMessaging.instance.getToken();
  } catch (e) {
    // Manejo de error silencioso
  }
}

Future<void> _clearChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history");
}
