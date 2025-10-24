import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/di/di.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDI();

  // Initialize and schedule daily notification
  try {
    final notificationService = getIt<NotificationService>();
    final prefs = getIt<SharedPreferences>();

    await notificationService.initialize();

    // Load saved notification time or use default (7:00 PM)
    final hour = prefs.getInt('notification_hour') ?? 19;
    final minute = prefs.getInt('notification_minute') ?? 0;
    final enabled = prefs.getBool('daily_notification_enabled') ?? true;

    if (enabled) {
      await notificationService.scheduleDailyReminder(hour: hour, minute: minute);
      if (kDebugMode) {
        print('✅ Notification service initialized and scheduled for $hour:${minute.toString().padLeft(2, '0')}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error initializing notifications: $e');
    }
  }

  runApp(const ExpenseApp());
}