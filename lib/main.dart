import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progresspal/firebase_options.dart';
import 'package:progresspal/services/firebase_service.dart';
import 'package:progresspal/services/hive_database.dart';
import 'package:progresspal/services/noti_service.dart';
import 'package:progresspal/themes/themes.dart';
import 'package:provider/provider.dart';

import 'models/streak_model.dart';
import 'pages/home_page.dart';
import 'providers/track_provider.dart';
import 'providers/streak_provider.dart';
import 'services/streak_checker.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notiService = NotiService();
  await notiService.initNotification();

  final notification = message.notification;
  final title = notification?.title ?? '';

  if (notification != null) {
    if (title.contains('Your streak is in danger!')) {
      final hasCompletedGoalToday =
          await StreakChecker().hasCompletedGoalsTodayFromHive();

      if (!hasCompletedGoalToday) {
        await notiService.showCustomNotification(
          id: 100,
          title: title,
          body: notification.body ?? '',
        );
      }
    } else {
      await notiService.showCustomNotification(
        id: 101,
        title: title,
        body: notification.body ?? '',
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Related to Notifications
  NotiService().initNotification();
  await NotiService().requestPermissions();

  // Related to Ads
  MobileAds.instance.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService().initNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProgressPal());
}

class ProgressPal extends StatefulWidget {
  const ProgressPal({super.key});

  @override
  State<ProgressPal> createState() => _ProgressPalState();
}

class _ProgressPalState extends State<ProgressPal> {
  bool _isLoading = true;
  late Box<StreakModel> streakBox;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await HiveDatabase().initHive(); // Initialize Hive and open boxes

    setState(() {
      _isLoading = false; // Set loading to false once initialization is done
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading screen while initializing
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Once loading is complete, show the actual app with multiple providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => StreakProvider()..loadStreak()),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
