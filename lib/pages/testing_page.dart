import 'package:flutter/material.dart';
import 'package:progresspal/services/noti_service.dart';
import 'package:timezone/timezone.dart' as tz;

class TestingPage extends StatelessWidget {
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Testing Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final scheduledDate = tz.TZDateTime.now(
                  tz.local,
                ).add(Duration(seconds: 15));
                NotiService().scheduleNotification(
                  title: 'Your streak is in danger!',
                  body: 'Complete a goal to improve and keep the streak',
                  scheduledDate: scheduledDate,
                );
              },
              child: Text('Schedule Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                final testTime = tz.TZDateTime.now(
                  tz.local,
                ).add(Duration(seconds: 20)); // adjust if needed

                NotiService().scheduleNotification(
                  title: '🧪 Test Reminder',
                  body: 'This simulates the next-day streak reminder!',
                  scheduledDate: testTime,
                );

                print('✅ Test notification scheduled for $testTime');
              },
              child: Text('Test Tomorrow Reminder'),
            ),
            ElevatedButton(
              onPressed: () {
                final testTime = tz.TZDateTime.now(
                  tz.local,
                ).add(Duration(seconds: 20)); // adjust if needed

                NotiService().sendNotiNow();

                print('✅ Test notification scheduled for Now');
              },
              child: Text('Test Now Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
