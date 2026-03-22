import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:nudge/data/services/quote_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    if (_initialized) return;
    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();
      
      // Use the device's actual local timezone via flutter_timezone
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('[Notif] Initialized timezone: $timeZoneName');

      // 2. Initialize the notifications plugin
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(initSettings);
      _initialized = true;
      debugPrint('[Notif] Plugin initialized successfully');
    } catch (e) {
      debugPrint('[Notif] Init Error: $e');
      // Fallback: try guessing if flutter_timezone fails
      try {
        final String fallbackTz = _guessLocalTimezone();
        tz.setLocalLocation(tz.getLocation(fallbackTz));
        debugPrint('[Notif] Fallback timezone set: $fallbackTz');
      } catch (_) {}
    }
  }

  /// Best-effort guess of IANA timezone name from UTC offset.
  String _guessLocalTimezone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.abs() % 60;
      for (final name in tz.timeZoneDatabase.locations.keys) {
        final loc = tz.timeZoneDatabase.locations[name]!;
        final now = tz.TZDateTime.now(loc);
        if (now.timeZoneOffset.inHours == hours &&
            now.timeZoneOffset.inMinutes.abs() % 60 == minutes) {
          return name;
        }
      }
    } catch (_) {}
    return 'GMT';
  }

  // ---------------------------------------------------------------------------
  // PERMISSIONS
  // ---------------------------------------------------------------------------

  Future<bool> requestPermissions() async {
    bool granted = false;
    try {
      // Android
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final result = await androidPlugin.requestNotificationsPermission();
        granted = result ?? false;
        debugPrint('[Notif] Android notification permission granted: $granted');

        // Also request exact alarm permission on Android 12+
        final exactAlarm =
            await androidPlugin.requestExactAlarmsPermission();
        debugPrint('[Notif] Exact alarm permission granted: $exactAlarm');
      }

      // iOS
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final result = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = result ?? false;
        debugPrint('[Notif] iOS notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('[Notif] Permission Request Error: $e');
    }
    return granted;
  }

  // ---------------------------------------------------------------------------
  // INSTANT / TEST NOTIFICATIONS
  // ---------------------------------------------------------------------------

  /// Fires an instant notification for settings-change confirmations.
  Future<void> showInstantNotification(String title, String body) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'nudge_updates',
        'App Updates',
        channelDescription: 'Notifications for settings and profile updates',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.show(999, title, body, details);
      debugPrint('[Notif] Instant notification shown: $title');
    } catch (e) {
      debugPrint('[Notif] Instant Notification Error: $e');
    }
  }

  /// Fires a test notification immediately — always uses show() for reliability.
  Future<void> showTestNotification(String quoteText) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'nudge_test',
        'Test Notifications',
        channelDescription: 'Test notifications for Nudge',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.show(0, '💡 Nudge', quoteText, details);
      debugPrint('[Notif] Test notification fired');
    } catch (e) {
      debugPrint('[Notif] Test Notification Error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SCHEDULED DAILY NOTIFICATIONS
  // ---------------------------------------------------------------------------

  /// Schedule [frequency] evenly-spaced daily notifications.
  ///
  /// Quiet hours: if [quietHoursEnabled] is true, notifications are confined to
  /// the window OUTSIDE of quiet hours (i.e. from [quietEnd] to [quietStart]).
  /// If quiet hours span midnight (e.g. 22:00 → 07:00), the active window is
  /// 07:00 → 22:00.
  Future<void> scheduleNotifications({
    required int frequency,
    required TimeOfDay quietStart,
    required TimeOfDay quietEnd,
    required bool quietHoursEnabled,
    required QuoteService quoteService,
    required List<String>? enabledCategories,
  }) async {
    try {
      // Cancel everything first
      await cancelAllNotifications();
      debugPrint('[Notif] Cancelled all existing notifications');

      if (frequency <= 0) {
        debugPrint('[Notif] Frequency is 0 — no notifications scheduled');
        return;
      }

      // Determine the active window in minutes-from-midnight
      int windowStartMinutes;
      int windowEndMinutes;

      if (quietHoursEnabled) {
        // Active window = outside quiet hours
        // quiet hours: quietStart → quietEnd
        // active window: quietEnd → quietStart
        windowStartMinutes = quietEnd.hour * 60 + quietEnd.minute;
        windowEndMinutes   = quietStart.hour * 60 + quietStart.minute;
      } else {
        // Default window: 08:00 → 22:00
        windowStartMinutes = 8 * 60;
        windowEndMinutes   = 22 * 60;
      }

      // Calculate total active window minutes, handling midnight span
      int windowMinutes;
      if (windowEndMinutes > windowStartMinutes) {
        windowMinutes = windowEndMinutes - windowStartMinutes;
      } else {
        // e.g. active 22:00 to 07:00 next day
        windowMinutes = (24 * 60 - windowStartMinutes) + windowEndMinutes;
      }

      if (windowMinutes <= 0) {
        debugPrint('[Notif] Active window is zero or negative — skipping');
        return;
      }

      // Space notifications evenly: divide window into (frequency + 1) slots
      final intervalMinutes = windowMinutes ~/ (frequency + 1);
      debugPrint(
          '[Notif] Window Start: ${_minutesToTime(windowStartMinutes)}, End: ${_minutesToTime(windowEndMinutes)}, '
          'Total Active: ${windowMinutes}min, Interval: ${intervalMinutes}min, Count: $frequency');

      int scheduledCount = 0;

      for (int i = 0; i < frequency; i++) {
        // Add interval, and wrap around 24h if it spans midnight
        final totalMinutes = (windowStartMinutes + ((i + 1) * intervalMinutes)) % 1440;
        final hour   = totalMinutes ~/ 60;
        final minute = totalMinutes % 60;

        final quote = quoteService.getRandomQuote(
          [],
          enabledCategories: enabledCategories,
        );

        await _scheduleDailyAt(
          id: i + 1,
          hour: hour,
          minute: minute,
          title: '💡 Nudge',
          body: quote.text,
        );
        scheduledCount++;
        debugPrint('[Notif] Scheduled notification #${i + 1} at ${_minutesToTime(totalMinutes)} → "${quote.text.substring(0, quote.text.length.clamp(0, 40))}..."');
      }

      debugPrint('[Notif] Total notifications scheduled: $scheduledCount');
    } catch (e) {
      debugPrint('[Notif] Error scheduling notifications: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // INTERNAL: zone-aware daily scheduler
  // ---------------------------------------------------------------------------

  Future<void> _scheduleDailyAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nudge_daily',
      'Daily Quotes',
      channelDescription: 'Daily motivational quote notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Returns the next [tz.TZDateTime] for the given [hour]:[minute] local time.
  /// If that time has already passed today, returns tomorrow's instance.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ---------------------------------------------------------------------------
  // CANCEL
  // ---------------------------------------------------------------------------

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[Notif] All notifications cancelled');
    } catch (e) {
      debugPrint('[Notif] Error cancelling notifications: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _minutesToTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
