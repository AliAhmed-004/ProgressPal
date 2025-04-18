import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize Plugin
  Future<void> initNotification() async {
    if (isInitialized) return;

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    // android init settings
    //TODO Change to App icon
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ios init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      iOS: initSettingsIOS,
      android: initSettingsAndroid,
    );

    // initialize the plugin
    await notificationsPlugin.initialize(initSettings);
  }

  // Notification Details Setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Reminds about completing the goals',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/notification_icon',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> sendNotiNow() async {
    await notificationsPlugin.show(
      2,
      'Now',
      'Testing Now',
      notificationDetails(),
      payload: null,
    );
  }

  Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id, // Any unique ID
      title,
      body,
      notificationDetails(),
      payload: null,
    );
  }

  // Schedule Notification
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    //required int hour,
    //required int minute,
  }) async {
    // Get current date/time in device's local timezone

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),

      //iOS Specific
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      // Android Specific
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // Make Notifications Repeat
      // matchDateTimeComponents: DateTimeComponents.time,
      payload: null,
    );
    print("Scheduling at: ${scheduledDate.toLocal()}");
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Request Permissions
  Future<void> requestPermissions() async {
    // Android (13+)
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // iOS
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
