import 'package:drift/drift.dart';
import 'measurement_tables.dart';

/// A scheduled, recurring reminder (§14). When [measurementTypeId] is
/// null the reminder is a general "update your measurements" nudge.
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get measurementTypeId => text().nullable().references(MeasurementTypes, #id)();
  TextColumn get frequency => text()();
  IntColumn get customIntervalDays => integer().nullable()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastFiredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
