import 'package:firebase_messaging/firebase_messaging.dart';
import 'noti_service.dart'; // Your NotiService file

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotiService _notiService = NotiService();

  // Initialize FCM
  Future<void> initNotifications() async {
    // Request notification permissions (especially for iOS)
    await _firebaseMessaging.requestPermission();

    // Get and print the device token
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _notiService.showCustomNotification(
          title: notification.title ?? 'No Title',
          body: notification.body ?? 'No Body',
        );
      }
    });

    // Optional: handle messages that open the app from background/tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked with data: ${message.data}");
      // You can navigate the user to a screen here if needed
    });
  }
}
