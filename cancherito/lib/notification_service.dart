import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Manejador global para notificaciones cuando la app está en segundo plano o cerrada.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint("Notificación en segundo plano recibida: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Solicitar permisos (fundamental para notificaciones push)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    debugPrint('Estado de permisos de notificación: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Obtener el token del dispositivo (Se usará en la S11/S12 para enviar notificaciones desde el backend)
      try {
        String? token = await _fcm.getToken();
        debugPrint("Token FCM del dispositivo: $token");
      } catch (e) {
        debugPrint("Error obteniendo token FCM: $e");
      }

      // 3. Escuchar notificaciones en segundo plano/cerrada
      FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

      // 4. Escuchar notificaciones mientras el usuario usa la app (primer plano)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Notificación recibida en primer plano: ${message.notification?.title}");
        // Aquí puedes agregar un ScaffoldMessenger para mostrar un SnackBar 
        // cuando llegue un aviso de "Reserva confirmada" si el usuario tiene la app abierta.
      });

      // 5. Manejar el evento cuando el usuario toca la notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("La app se abrió desde una notificación: ${message.notification?.title}");
      });
    }
  }
}