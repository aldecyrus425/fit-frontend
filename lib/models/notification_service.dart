import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService{

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tapped logic here if needed
        print("Notification clicked: ${details.payload}");
      },
    );
  }

  Future<void> showNotification({int id = 0, String title = "Notificaiton", String body = "This is a notification message"}) async {

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      "default_channel",
      "Default Channel",
      channelDescription: "This is a default notification channel",
      importance: Importance.max, // <- required
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails
    );
    await _notificationsPlugin.show(id: id, title: title, body: body, notificationDetails: notificationDetails);
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "scheduled_channel",
      "Scheduled Channel",
      channelDescription: "Notifications scheduled from backend",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local), // <- correct
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
