import 'package:drift/drift.dart';

/// A *kind* of measurement (e.g. "chest", "weight"). Storing types as rows
/// instead of hard-coded columns is what makes the schema extensible
/// (§35) — a brand-new measurement type is just a new row, never a
/// migration.
@DataClassName('MeasurementTypeRow')
class MeasurementTypes extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  TextColumn get displayName => text()();
  TextColumn get canonicalUnit => text()();
  TextColumn get instructions => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isTracked => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single historical value for a [MeasurementTypes] row. Never updated
/// in place when a "new" value is recorded — always inserted (§6).
@DataClassName('MeasurementRow')
class Measurements extends Table {
  TextColumn get id => text()();
  TextColumn get typeId => text().references(MeasurementTypes, #id)();
  RealColumn get valueCanonical => real()();
  TextColumn get unit => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
