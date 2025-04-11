import 'package:flutter/material.dart';
import 'package:progresspal/services/noti_service.dart';
import 'package:timezone/timezone.dart' as tz;

class TestingPage extends StatelessWidget {
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final scheduledDate = tz.TZDateTime.now(
                  tz.local,
                ).add(Duration(seconds: 35));
                NotiService().scheduleNotification(
                  title: 'Your streak is in danger!',
                  body: 'Complete a goal to improve and keep the streak',
                  scheduledDate: scheduledDate,
                );
              },
              child: Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
