import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/domain/entities/reminder.dart';
import 'package:measure_me/integrations/notifications/reminder_scheduler.dart';

Reminder _reminder({
  required ReminderFrequency frequency,
  int? customIntervalDays,
  DateTime? lastFiredAt,
  required DateTime createdAt,
  int hour = 9,
  int minute = 0,
}) {
  return Reminder(
    id: 'test',
    frequency: frequency,
    customIntervalDays: customIntervalDays,
    hour: hour,
    minute: minute,
    enabled: true,
    lastFiredAt: lastFiredAt,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  group('ReminderScheduler.nextOccurrence', () {
    test('never-fired reminder anchors to its creation day if still upcoming', () {
      final createdAt = DateTime(2026, 6, 1);
      final reminder = _reminder(frequency: ReminderFrequency.monthly, createdAt: createdAt, hour: 9, minute: 0);
      final from = DateTime(2026, 6, 1, 8); // earlier the same morning

      final next = ReminderScheduler.nextOccurrence(reminder, from: from);
      expect(next, DateTime(2026, 6, 1, 9, 0));
    });

    test('advances by the interval until a future time is reached', () {
      final createdAt = DateTime(2026, 1, 1, 9, 0);
      final reminder = _reminder(frequency: ReminderFrequency.monthly, createdAt: createdAt);
      final from = DateTime(2026, 6, 15); // long after creation, never fired

      final next = ReminderScheduler.nextOccurrence(reminder, from: from);
      expect(next.isAfter(from), isTrue);
      // Monthly = 30-day steps from Jan 1, 2026: 6 steps of 30 days lands
      // exactly on June 30, the first occurrence strictly after June 15.
      expect(next, DateTime(2026, 6, 30, 9, 0));
    });

    test('anchors to lastFiredAt once the reminder has fired before', () {
      final createdAt = DateTime(2026, 1, 1, 9, 0);
      final lastFiredAt = DateTime(2026, 5, 1, 9, 0);
      final reminder = _reminder(
        frequency: ReminderFrequency.monthly,
        createdAt: createdAt,
        lastFiredAt: lastFiredAt,
      );
      final from = DateTime(2026, 5, 2);

      final next = ReminderScheduler.nextOccurrence(reminder, from: from);
      expect(next, DateTime(2026, 5, 31, 9, 0));
    });

    test('custom frequency uses customIntervalDays', () {
      final createdAt = DateTime(2026, 1, 1, 9, 0);
      final reminder = _reminder(
        frequency: ReminderFrequency.custom,
        customIntervalDays: 10,
        createdAt: createdAt,
      );
      final from = DateTime(2026, 1, 15);

      final next = ReminderScheduler.nextOccurrence(reminder, from: from);
      expect(next, DateTime(2026, 1, 21, 9, 0));
    });

    test('weekly frequency advances by 7 days', () {
      final createdAt = DateTime(2026, 1, 1, 9, 0);
      final reminder = _reminder(frequency: ReminderFrequency.weekly, createdAt: createdAt);
      final next = ReminderScheduler.nextOccurrence(reminder, from: DateTime(2026, 1, 1, 9, 0));
      expect(next, DateTime(2026, 1, 8, 9, 0));
    });
  });
}
