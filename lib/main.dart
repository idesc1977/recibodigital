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
import 'globals.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔄 Widget que permite reiniciar toda la app en caliente (iOS)
class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

/// 👇 Handler de mensajes en segundo plano (DEBE ir en el main)
@pragma('vm:entry-point') // Necesario para iOS en release
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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
    runApp(RestartWidget(child: const MyApp()));
  }, (error, stack) {
    runApp(ErrorApp(error.toString()));
  });
}

Future<void> initializeApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initializeLocalNotifications();
  await _requestNotificationPermissions();
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  _setupMessageListeners();

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
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {},
  );
}

Future<void> _requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
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
      if (apnsToken == null) {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
    }
    tokenfirebase = await FirebaseMessaging.instance.getToken();
  } catch (_) {}
}

Future<void> _clearChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history");
}
