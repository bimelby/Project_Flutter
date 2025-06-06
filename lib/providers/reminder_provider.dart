/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foshmed/models/reminder.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  List<Reminder> get reminders => [..._reminders];
  List<Reminder> get activeReminders =>
      _reminders.where((r) => r.isActive).toList();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    await _loadReminders();
    _isInitialized = true;
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders') ?? [];

    _reminders = remindersJson
        .map((json) => Reminder.fromJson(jsonDecode(json)))
        .toList();

    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();

    await prefs.setStringList('reminders', remindersJson);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();

    if (reminder.isActive && reminder.dateTime.isAfter(DateTime.now())) {
      await _scheduleNotification(reminder);
    }

    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      _reminders[index] = reminder;
      await _saveReminders();

      // Cancel existing notification
      await _notificationsPlugin.cancel(reminder.id.hashCode);

      // Schedule new notification if active
      if (reminder.isActive && reminder.dateTime.isAfter(DateTime.now())) {
        await _scheduleNotification(reminder);
      }

      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    await _notificationsPlugin.cancel(reminderId.hashCode);
    _reminders.removeWhere((r) => r.id == reminderId);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    const androidDetails = AndroidNotificationDetails(
      'foshmed_reminders',
      'Foshmed Reminders',
      channelDescription: 'Reminders for your diary entries',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(reminder.dateTime, tz.local), 
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleBreakReminder() async {
    final now = DateTime.now();
    final breakTime = now.add(const Duration(hours: 1));

    final reminder = Reminder(
      id: 'break_${now.millisecondsSinceEpoch}',
      entryId: '',
      title: 'Time for a Break! 🌿',
      description: 'You\'ve been working for an hour. Take a 5-minute break!',
      dateTime: breakTime,
      isActive: true,
      type: 'break',
    );

    await addReminder(reminder);
  }
}
*/