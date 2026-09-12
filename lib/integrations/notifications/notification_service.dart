import '../../domain/entities/reminder.dart';

/// Local-notification contract used by the rest of the app. Kept separate
/// from [ReminderScheduler] (the pure date math) so the plugin-backed
/// implementation stays swappable/testable (§17, §19).
abstract class NotificationService {
  /// Must be called once before scheduling anything.
  Future<void> initialize();

  /// Requests OS notification permission. Only called the first time the
  /// user creates/enables a reminder (§33), never at launch.
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  /// Schedules (or reschedules) the next single occurrence for
  /// [reminder]. Because OS-level recurrence rules can't express
  /// arbitrary "every N days" cadences, MeasureMe reschedules the next
  /// occurrence itself each time reminders are reconciled (on app start
  /// and whenever a reminder changes) rather than relying on infinite
  /// native recurrence.
  Future<void> scheduleReminder(Reminder reminder);

  Future<void> cancelReminder(String reminderId);

  /// Re-schedules every enabled, past-due-or-unscheduled reminder. Safe
  /// to call on every app start.
  Future<void> reconcileAll(List<Reminder> reminders);

  /// Emits the reminder id (from the notification payload) whenever the
  /// user taps a MeasureMe notification, so the UI can open the
  /// measurement update flow (§14).
  Stream<String> get onReminderTapped;
}
