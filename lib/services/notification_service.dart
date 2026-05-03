import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('UTC'));
    } catch (e) {
      debugPrint("Timezone error: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );

    if (!kIsWeb) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation;
      final androidImpl = androidPlugin<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'Task Alerts',
            description: 'Used for important task alerts',
            importance: Importance.max,
            playSound: true,
          ),
        );
        await androidImpl.requestNotificationsPermission();
      }
    }
  }

  Future<void> playRingtone() async {
    try {
      debugPrint("Playing ringtone...");
      await _audioPlayer.stop();
      if (kIsWeb) {
        await _audioPlayer.play(UrlSource('assets/audio/ringtone.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('audio/ringtone.mp3'));
      }
    } catch (e) {
      debugPrint("Error playing ringtone: $e");
    }
  }

  Future<void> showTaskCompletedNotification(String taskTitle) async {
    await playRingtone();

    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'Task Alerts',
      channelDescription: 'Used for important task alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecondsSinceEpoch % 1000000,
      "Task Completed!",
      "Great job! '$taskTitle' is finished.",
      platformDetails,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    if (kIsWeb) return;
    if (scheduledTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Task Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}