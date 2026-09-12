import '../../domain/entities/reminder.dart';

/// Pure scheduling math for [Reminder]s — kept free of any notification
/// plugin dependency so it's trivially unit-testable (§34).
class ReminderScheduler {
  ReminderScheduler._();

  /// Computes the next fire date/time strictly after [from], based on the
  /// reminder's frequency and last-fired date. If the reminder has never
  /// fired, it's anchored to [Reminder.createdAt].
  ///
  /// Advances by whole calendar days (via the [DateTime] constructor's
  /// day-overflow normalization) rather than by adding a [Duration] —
  /// adding a fixed-length [Duration] repeatedly accumulates drift across
  /// daylight-saving transitions, which would silently shift a reminder's
  /// wall-clock time by an hour.
  static DateTime nextOccurrence(Reminder reminder, {required DateTime from}) {
    final intervalDays = reminder.intervalDays;
    final anchor = reminder.lastFiredAt ?? reminder.createdAt;

    DateTime atReminderTime(DateTime day) =>
        DateTime(day.year, day.month, day.day, reminder.hour, reminder.minute);

    var candidateDay = DateTime(anchor.year, anchor.month, anchor.day);
    var candidate = atReminderTime(candidateDay);

    // If never fired, the very first occurrence is the anchor day itself
    // (if still in the future) rather than one interval later.
    if (reminder.lastFiredAt == null && candidate.isAfter(from)) {
      return candidate;
    }

    while (!candidate.isAfter(from)) {
      candidateDay = DateTime(candidateDay.year, candidateDay.month, candidateDay.day + intervalDays);
      candidate = atReminderTime(candidateDay);
    }
    return candidate;
  }
}
