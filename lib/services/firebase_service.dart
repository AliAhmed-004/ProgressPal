import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  // create instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize settings
  Future<void> initNotifications() async {
    // request permissions
    await _firebaseMessaging.requestPermission();

    // fetch FCM token for the device
    final fcmToken = await _firebaseMessaging.getToken();
    print("Token: $fcmToken");
  }

  // function to handle recieved message

  // function to initialize foreground and background settings
}
