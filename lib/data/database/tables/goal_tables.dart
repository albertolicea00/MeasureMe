import 'package:drift/drift.dart';
import 'measurement_tables.dart';

/// A user-defined target for a measurement type (§26) — never a medical
/// recommendation, just a personal goal.
@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get measurementTypeId => text().references(MeasurementTypes, #id).unique()();
  RealColumn get targetValueCanonical => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
