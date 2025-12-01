import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
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
  final data = message.data;
  final type = data['type'] ?? 'default';

  final title = notification?.title ?? '';
  final body = notification?.body ?? '';

  if (notification != null) {
    if (type == 'reminder') {
      final hasCompletedGoal =
          await StreakChecker().hasCompletedGoalsTodayFromHive();
      if (!hasCompletedGoal) {
        await notiService.showCustomNotification(
          id: 100,
          title: title,
          body: body,
        );
      }
    } else {
      // For other types like 'motivational', show without check
      await notiService.showCustomNotification(
        id: 101,
        title: title,
        body: body,
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only critical services before runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveDatabase().initHive();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ProgressPal(),
    ),
  );

  // Deferred init (non-blocking UI)
  _initializeServicesInBackground();
}

Future<void> _initializeServicesInBackground() async {
  // Request notification permissions
  await NotiService().requestPermissions();

  // Init local notifications
  NotiService().initNotification();

  // Set background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Init Firebase notifications (e.g., topics, foreground handlers)
  await FirebaseService().initNotifications();

  // Initialize AdMob (deferred for speed)
  await MobileAds.instance.initialize();
}

class ProgressPal extends StatefulWidget {
  const ProgressPal({super.key});

  @override
  State<ProgressPal> createState() => _ProgressPalState();
}

class _ProgressPalState extends State<ProgressPal> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check if onboarding has been completed
    final settingsBox = Hive.box(HiveDatabase.settingsBoxName);
    final onboardingComplete = settingsBox.get(
      'onboardingComplete',
      defaultValue: false,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoading = false;
      _showOnboarding = !onboardingComplete;
    });
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
            home: _showOnboarding ? const OnboardingPage() : const HomePage(),
          ),
        );
  }
}
