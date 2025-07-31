// main.dart
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

    await _initializeApp();

    runApp(const MyApp());
  }, (error, stack) {
    runApp(ErrorApp(error.toString()));
  });
}

Future<void> _initializeApp() async {
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
      navigatorKey: navigatorKey,
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
  // Si aún no hay contexto (por ejemplo, antes del runApp final),
  // hacemos el flujo silencioso para no fallar.
  final ctx = navigatorKey.currentContext;
  if (ctx == null) {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      tokenfirebase = await FirebaseMessaging.instance.getToken();
    } catch (_) {}
    return;
  }

  // Notifiers para actualizar el diálogo en vivo
  final logs = ValueNotifier<List<String>>([]);
  final apnsVN = ValueNotifier<String?>(null); // iOS
  final fcmVN = ValueNotifier<String?>(null);

  void log(String m) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    logs.value = [...logs.value, "$ts • $m"];
    // Aviso corto en pantalla
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text(m), duration: const Duration(seconds: 2)),
    );
  }

  // Abre el diálogo (no bloqueante)
  // ignore: unawaited_futures
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        title: const Text('Diagnóstico FCM / APNs'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Platform.isIOS)
                ValueListenableBuilder<String?>(
                  valueListenable: apnsVN,
                  builder: (_, apns, __) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "APNs: ${apns == null ? '(null)' : '${apns.substring(0, 8)}…'}"),
                  ),
                ),
              const SizedBox(height: 6),
              ValueListenableBuilder<String?>(
                valueListenable: fcmVN,
                builder: (_, fcm, __) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "FCM: ${fcm == null ? '(null)' : '${fcm.substring(0, 12)}…'}"),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: logs,
                  builder: (_, list, __) => ListView(
                    shrinkWrap: true,
                    children: list.map((e) => Text("• $e")).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final f = fcmVN.value;
              if (f == null || f.isEmpty) return;
              await Clipboard.setData(ClipboardData(text: f));
              if (navigatorKey.currentContext != null) {
                ScaffoldMessenger.of(navigatorKey.currentContext!)
                    .showSnackBar(const SnackBar(content: Text('FCM copiado')));
              }
            },
            child: const Text('Copiar FCM'),
          ),
          if (Platform.isIOS)
            TextButton(
              onPressed: () async {
                final a = apnsVN.value;
                if (a == null || a.isEmpty) return;
                await Clipboard.setData(ClipboardData(text: a));
                if (navigatorKey.currentContext != null) {
                  ScaffoldMessenger.of(navigatorKey.currentContext!)
                      .showSnackBar(
                          const SnackBar(content: Text('APNs copiado')));
                }
              },
              child: const Text('Copiar APNs'),
            ),
          TextButton(
            onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );

  // Corre la lógica de obtención mientras el diálogo está abierto
  try {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    log("Auto-init activado.");

    // Intento directo
    tokenfirebase = await FirebaseMessaging.instance.getToken();
    fcmVN.value = tokenfirebase;
    log("FCM (directo): ${tokenfirebase == null ? 'null' : 'obtenido'}");

    // iOS: ver APNs
    if (Platform.isIOS) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      apnsVN.value = apns;
      log("APNs: ${apns == null ? 'null' : 'obtenido'}");
    }

    // Si aún no hay FCM, escuchamos onTokenRefresh + reintentos cortos
    if (tokenfirebase == null) {
      log("Sin FCM aún. Intentando reintentos y onTokenRefresh…");
      final completer = Completer<String?>();
      final sub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (!completer.isCompleted) {
          log("onTokenRefresh emitió token.");
          completer.complete(newToken);
        }
      });

      String? direct;
      for (var i = 0; i < 6 && direct == null; i++) {
        await Future.delayed(const Duration(seconds: 1));
        direct = await FirebaseMessaging.instance.getToken();
        log("Reintento ${i + 1}: ${direct == null ? 'sin token' : 'token obtenido'}");
        if (direct != null && !completer.isCompleted) {
          completer.complete(direct);
        }
      }

      tokenfirebase = await completer.future
          .timeout(const Duration(seconds: 7), onTimeout: () => null);
      await sub.cancel();

      fcmVN.value = tokenfirebase;
      log("Resultado final FCM: ${tokenfirebase == null ? 'null' : 'obtenido'}");
    }
  } catch (e) {
    log("Error: $e");
  }
}

Future<void> _clearChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("chat_history");
}
