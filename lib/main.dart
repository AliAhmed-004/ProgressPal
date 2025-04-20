import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'providers/streak_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/track_provider.dart';
import 'services/firebase_service.dart';
import 'services/hive_database.dart';
import 'services/noti_service.dart';
import 'services/streak_checker.dart';
import 'themes/themes.dart';

// Background notification handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notiService = NotiService();
  await notiService.initNotification();

  final notification = message.notification;
  final title = notification?.title ?? '';

  if (notification != null) {
    final isReminder = title.contains('Stay on top of your game!');
    final hasCompletedGoal =
        await StreakChecker().hasCompletedGoalsTodayFromHive();

    if (!hasCompletedGoal || !isReminder) {
      await notiService.showCustomNotification(
        id: isReminder ? 100 : 101,
        title: title,
        body: notification.body ?? '',
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init services
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveDatabase().initHive();
  await NotiService().requestPermissions();
  NotiService().initNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseService().initNotifications();
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ProgressPal(),
    ),
  );
}

class ProgressPal extends StatefulWidget {
  const ProgressPal({super.key});

  @override
  State<ProgressPal> createState() => _ProgressPalState();
}

class _ProgressPalState extends State<ProgressPal> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Already initialized Hive in main(), so just simulate a short delay if needed
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return _isLoading
        ? MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.currentTheme,
          home: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        )
        : MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => TrackProvider()..loadEntries(),
            ),
            ChangeNotifierProvider(
              create: (_) => StreakProvider()..loadStreak(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.currentTheme,
            home: const HomePage(),
          ),
        );
  }
}
