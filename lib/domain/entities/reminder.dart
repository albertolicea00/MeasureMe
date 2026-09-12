/// How often a reminder recurs (§14).
enum ReminderFrequency { weekly, biweekly, monthly, everyThreeMonths, custom }

extension ReminderFrequencyLabel on ReminderFrequency {
  String get label {
    switch (this) {
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.biweekly:
        return 'Every 2 weeks';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.everyThreeMonths:
        return 'Every 3 months';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  int? get days {
    switch (this) {
      case ReminderFrequency.weekly:
        return 7;
      case ReminderFrequency.biweekly:
        return 14;
      case ReminderFrequency.monthly:
        return 30;
      case ReminderFrequency.everyThreeMonths:
        return 90;
      case ReminderFrequency.custom:
        return null;
    }
  }
}

/// A scheduled, recurring reminder to update measurements. When
/// [measurementTypeId] is null, the reminder covers a general "update your
/// measurements" session; otherwise it targets a single measurement type.
class Reminder {
  final String id;
  final String? measurementTypeId;
  final ReminderFrequency frequency;
  final int? customIntervalDays;
  final int hour;
  final int minute;
  final bool enabled;
  final DateTime? lastFiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    this.measurementTypeId,
    required this.frequency,
    this.customIntervalDays,
    required this.hour,
    required this.minute,
    required this.enabled,
    this.lastFiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int get intervalDays => frequency == ReminderFrequency.custom
      ? (customIntervalDays ?? 30)
      : (frequency.days ?? 30);

  Reminder copyWith({
    String? measurementTypeId,
    bool clearMeasurementTypeId = false,
    ReminderFrequency? frequency,
    int? customIntervalDays,
    int? hour,
    int? minute,
    bool? enabled,
    DateTime? lastFiredAt,
  }) {
    return Reminder(
      id: id,
      measurementTypeId:
          clearMeasurementTypeId ? null : (measurementTypeId ?? this.measurementTypeId),
      frequency: frequency ?? this.frequency,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      lastFiredAt: lastFiredAt ?? this.lastFiredAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
