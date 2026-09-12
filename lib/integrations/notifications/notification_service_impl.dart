import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/reminder.dart';
import 'notification_service.dart';
import 'reminder_scheduler.dart';

const _channelId = 'measurement_reminders';
const _channelName = 'Measurement reminders';
const _channelDescription = 'Reminders to update your body measurements';

class NotificationServiceImpl implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _tapController = StreamController<String>.broadcast();
  bool _initialized = false;

  @override
  Stream<String> get onReminderTapped => _tapController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      // Fall back to UTC if the platform timezone name can't be resolved;
      // reminders will still fire, just anchored to UTC wall-clock time.
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _tapController.add(payload);
        }
      },
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return await androidImpl.areNotificationsEnabled() ?? false;
    }
    final iosImpl =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      // The Darwin plugin doesn't expose a direct "current status" query;
      // requesting with no new permission types returns the existing state.
      return await iosImpl.requestPermissions() ?? false;
    }
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission() ?? false;
    }
    final iosImpl =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      return await iosImpl.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  int _notificationIdFor(String reminderId) => reminderId.hashCode & 0x7fffffff;

  @override
  Future<void> scheduleReminder(Reminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.enabled) return;

    final next = ReminderScheduler.nextOccurrence(reminder, from: DateTime.now());
    final scheduledDate = tz.TZDateTime.from(next, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: _notificationIdFor(reminder.id),
        title: 'Time to update your measurements',
        body: reminder.measurementTypeId == null
            ? 'It\'s time for your scheduled measurement update.'
            : 'It\'s time to update this measurement.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.id,
      );
    } catch (e) {
      throw NotificationSchedulingException(
        'Unable to schedule the reminder. Please check notification permissions.',
      );
    }
  }

  @override
  Future<void> cancelReminder(String reminderId) async {
    await _plugin.cancel(id: _notificationIdFor(reminderId));
  }

  @override
  Future<void> reconcileAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      if (reminder.enabled) {
        await scheduleReminder(reminder);
      } else {
        await cancelReminder(reminder.id);
      }
    }
  }
}
