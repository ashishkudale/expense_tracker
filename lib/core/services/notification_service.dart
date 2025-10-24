import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // List of catchy notification messages to encourage users to add transactions
  static const List<String> _catchyTitles = [
    "💰 Forgot Something?",
    "🔔 Daily Money Check!",
    "📊 Track Your Spending!",
    "⏰ Expense Reminder!",
    "💸 Where's Your Money?",
  ];

  static const List<String> _catchyBodies = [
    "Don't let today's expenses slip away! Log them now and stay on top of your budget 💪",
    "Your future self will thank you! Take 30 seconds to add today's transactions 🎯",
    "Every penny counts! Did you spend anything today? Track it before you forget 📝",
    "Smart people track their money. Be smart - add your expenses now! 🧠",
    "Financial freedom starts with tracking! Add today's transactions and take control 🚀",
  ];

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Set local timezone with fallback
    try {
      // Try to detect system timezone
      final String timeZoneName = DateTime.now().timeZoneName;

      // Common timezone mappings for different regions
      String tzLocation;
      if (timeZoneName.contains('IST') || timeZoneName.contains('India')) {
        tzLocation = 'Asia/Kolkata';
      } else if (timeZoneName.contains('PKT') || timeZoneName.contains('Pakistan')) {
        tzLocation = 'Asia/Karachi';
      } else if (timeZoneName.contains('PST')) {
        tzLocation = 'America/Los_Angeles';
      } else if (timeZoneName.contains('EST')) {
        tzLocation = 'America/New_York';
      } else if (timeZoneName.contains('GMT') || timeZoneName.contains('UTC')) {
        tzLocation = 'UTC';
      } else {
        // Default fallback - try UTC first
        tzLocation = 'UTC';
      }

      tz.setLocalLocation(tz.getLocation(tzLocation));

      if (kDebugMode) {
        print('🌍 Timezone detected: $timeZoneName');
        print('🌍 Using timezone: $tzLocation');
        print('🕐 Current local time: ${tz.TZDateTime.now(tz.local)}');
      }
    } catch (e) {
      // Ultimate fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
      if (kDebugMode) {
        print('⚠️  Timezone detection failed, using UTC: $e');
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // Request notification permission (Android 13+)
      await androidImpl.requestNotificationsPermission();

      // Request exact alarm permission (Android 12+)
      final exactAlarmGranted = await androidImpl.requestExactAlarmsPermission();
      if (kDebugMode) {
        print('⏰ Exact alarm permission: ${exactAlarmGranted ?? 'granted'}');
      }
    }

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigation logic can be added here if needed
    // For example, navigate to the add transaction page
  }

  /// Schedule daily notification at specified time
  Future<void> scheduleDailyReminder({int hour = 19, int minute = 0}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel any existing scheduled notifications
    await _notifications.cancel(0);

    // Get random catchy title and body
    final random = Random();
    final title = _catchyTitles[random.nextInt(_catchyTitles.length)];
    final body = _catchyBodies[random.nextInt(_catchyBodies.length)];

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    final now = tz.TZDateTime.now(tz.local);

    if (kDebugMode) {
      print('⏰ === SCHEDULING NOTIFICATION ===');
      print('📅 Current time: $now');
      print('📅 Scheduled time: $scheduledTime');
      print('⏱️  Time until notification: ${scheduledTime.difference(now)}');
      print('📝 Title: $title');
      print('📝 Body: $body');
      print('🔧 Schedule Mode: exactAllowWhileIdle');
      print('🔧 Match Components: DateTimeComponents.time (daily repeat)');
    }

    try {
      // Schedule for specified time daily
      await _notifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Transaction Reminder',
            channelDescription: 'Reminds you to add transactions daily',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      if (kDebugMode) {
        print('✅ Notification scheduled successfully!');
        print('================================\n');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling notification: $e');
      }
      rethrow;
    }
  }

  /// Calculate next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Send immediate notification (for testing or manual trigger)
  Future<void> sendImmediateReminder() async {
    if (!_isInitialized) {
      await initialize();
    }

    final random = Random();
    final title = _catchyTitles[random.nextInt(_catchyTitles.length)];
    final body = _catchyBodies[random.nextInt(_catchyBodies.length)];

    if (kDebugMode) {
      print('🔔 Sending immediate notification...');
      print('📝 Title: $title');
      print('📝 Body: $body');
    }

    await _notifications.show(
      1, // Different ID for immediate notifications
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Transaction Reminder',
          channelDescription: 'Reminds you to add transactions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    if (kDebugMode) {
      print('✅ Immediate notification sent!');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? false;
    }

    return true; // Assume enabled for iOS
  }

  /// Check if app can schedule exact alarms (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (!_isInitialized) {
      await initialize();
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final canSchedule = await android.canScheduleExactNotifications();
      return canSchedule ?? true;
    }

    return true; // iOS doesn't need this
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestExactAlarmsPermission();
      if (kDebugMode) {
        print('⏰ Exact alarm permission requested: ${granted ?? 'granted'}');
      }
      return granted ?? true;
    }

    return true; // iOS doesn't need this
  }

  /// Get pending notification requests (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Debug: Print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    final now = tz.TZDateTime.now(tz.local);

    if (kDebugMode) {
      print('\n🔍 === PENDING NOTIFICATIONS DEBUG ===');
      print('🕐 Current time: $now');
      print('🌍 Timezone: ${tz.local.name}');
      print('📊 Total pending: ${pending.length}');

      if (pending.isEmpty) {
        print('⚠️  No pending notifications found!');
        print('   This means the notification was not scheduled.');
        print('   Possible reasons:');
        print('   - Exact alarm permission not granted');
        print('   - Scheduling failed silently');
        print('   - Notification was already triggered');
      } else {
        for (var notification in pending) {
          print('📌 Notification ID: ${notification.id}');
          print('   Title: ${notification.title}');
          print('   Body: ${notification.body}');
          print('   Payload: ${notification.payload}');
        }
      }

      // Check notification permission status
      final enabled = await areNotificationsEnabled();
      print('\n🔔 Notification permission: ${enabled ? "✅ Granted" : "❌ Denied"}');

      // Check exact alarm permission (Android 12+)
      final androidImpl = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final canSchedule = await androidImpl.canScheduleExactNotifications();
        print('⏰ Exact alarm permission: ${canSchedule == true ? "✅ Granted" : "❌ Denied or Unknown"}');
        if (canSchedule != true) {
          print('   ⚠️  WARNING: Without exact alarm permission, scheduled notifications may not work!');
        }
      }

      print('================================\n');
    }
  }
}
