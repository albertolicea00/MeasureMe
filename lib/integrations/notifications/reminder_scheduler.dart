import '../../domain/entities/reminder.dart';

/// Pure scheduling math for [Reminder]s — kept free of any notification
/// plugin dependency so it's trivially unit-testable (§34).
class ReminderScheduler {
  ReminderScheduler._();

  /// Computes the next fire date/time strictly after [from], based on the
  /// reminder's frequency and last-fired date. If the reminder has never
  /// fired, it's anchored to [Reminder.createdAt].
  static DateTime nextOccurrence(Reminder reminder, {required DateTime from}) {
    final intervalDays = reminder.intervalDays;
    final anchor = reminder.lastFiredAt ?? reminder.createdAt;

    var candidate = DateTime(anchor.year, anchor.month, anchor.day, reminder.hour, reminder.minute);

    // If never fired, the very first occurrence is the anchor day itself
    // (if still in the future) rather than one interval later.
    if (reminder.lastFiredAt == null && candidate.isAfter(from)) {
      return candidate;
    }

    while (!candidate.isAfter(from)) {
      candidate = candidate.add(Duration(days: intervalDays));
    }
    return candidate;
  }
}
