import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'cashe_helper.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get notificationsPlugin =>
      _notificationsPlugin;

  static const int dailyReminderID = 100;
  static const int afterCheckinReminderID = 200;

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      try {
        tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
      } catch (e) {
        if (kDebugMode) {
          print('Failed to set Asia/Baghdad timezone: $e');
        }
        try {
          tz.setLocalLocation(tz.local);
        } catch (e2) {
          tz.setLocalLocation(tz.getLocation('UTC'));
          if (kDebugMode) {
            print('Using UTC timezone as fallback');
          }
        }
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await requestPermissions();

      if (kDebugMode) {
        print(
          'LocalNotificationService initialized with timezone: ${tz.local.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing LocalNotificationService: $e');
      }
      rethrow;
    }
  }

  void setTimeZone(String timeZoneName) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) {
        print('Timezone set to: $timeZoneName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set timezone $timeZoneName: $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;

    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      // On iOS, accept both granted and provisional status
      if (kDebugMode) {
        print('Permission status after request: ${status.toString()}');
        print(
          'isGranted: ${status.isGranted}, isProvisional: ${status.isProvisional}',
        );
      }
      granted = Platform.isIOS
          ? (status.isGranted || status.isProvisional)
          : status.isGranted;
    } else {
      final status = await Permission.notification.status;
      // On iOS, accept both granted and provisional status
      if (kDebugMode) {
        print('Permission status (already requested): ${status.toString()}');
        print(
          'isGranted: ${status.isGranted}, isProvisional: ${status.isProvisional}',
        );
      }
      granted = Platform.isIOS
          ? (status.isGranted || status.isProvisional)
          : status.isGranted;
    }

    final bool? iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (kDebugMode) {
      print('Notification permission granted: $granted');
      if (iosGranted != null) {
        print('iOS notification permission granted: $iosGranted');
      }
    }

    return granted || (iosGranted ?? false);
  }

  Future<void> scheduleDailyReminder() async {
    if (!CacheHelper.isDailyReminderEnabled) {
      if (kDebugMode) {
        print('Daily reminder is disabled');
      }
      return;
    }

    try {
      await cancelDailyReminder();

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        9,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        dailyReminderID,
        'Attendance Reminder',
        'Don\'t forget to check in today!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily attendance reminders at 9:00 AM',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
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
        print('Daily reminder scheduled for: $scheduledDate');
        print('Current time: $now');
        print('Next reminder at: 9:00 AM every day');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule daily reminder: $e');
      }
    }
  }

  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(dailyReminderID);
    if (kDebugMode) {
      print('Daily reminder canceled');
    }
  }

  Future<void> scheduleAfterCheckinReminder(DateTime checkinTime) async {
    try {
      await cancelAfterCheckinReminder();

      final DateTime reminderTime = checkinTime.add(const Duration(hours: 8));
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminderTime,
        tz.local,
      );

      if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notificationsPlugin.zonedSchedule(
          afterCheckinReminderID,
          'Time to Check Out',
          'You checked in 8 hours ago. Don\'t forget to check out!',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'checkin_reminder_channel',
              'Check-in Reminders',
              channelDescription: 'Reminders 8 hours after check-in',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        await CacheHelper.setLastCheckinTime(checkinTime);

        if (kDebugMode) {
          print('After check-in reminder scheduled for: $scheduledDate');
        }
      } else {
        if (kDebugMode) {
          print('Scheduled time is in the past, not scheduling notification');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule after check-in reminder: $e');
      }
    }
  }

  Future<void> cancelAfterCheckinReminder() async {
    await _notificationsPlugin.cancel(afterCheckinReminderID);
    if (kDebugMode) {
      print('After check-in reminder canceled');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('All notifications canceled');
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    await CacheHelper.setDailyReminderEnabled(enabled);
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }
  }

  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      999,
      'Test Notification',
      'This is a test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    if (kDebugMode) {
      print('Test notification shown');
    }
  }
}
