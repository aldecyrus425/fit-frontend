import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ✅ Initialize plugin + permissions
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("🔔 Notification clicked: ${details.payload}");
      },
    );

    final androidPlugin =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ✅ Request permissions
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// ✅ Schedule notification (alarm-style)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print("📌 Scheduling notification...");
    print("🕒 Input DateTime: $scheduledDate");

    final tzTime = tz.TZDateTime.from(scheduledDate, tz.local);

    print("🌍 TZ Time: $tzTime");

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      "scheduled_channel",
      "Scheduled Notifications",
      channelDescription: "Notifications scheduled from backend",
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // optional repeating behavior
    );

    print("✅ Notification scheduled successfully");
  }
}