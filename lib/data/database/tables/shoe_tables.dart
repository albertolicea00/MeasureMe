import 'package:drift/drift.dart';

/// A brand-specific shoe size the user has confirmed fits them (§12, §13).
@DataClassName('ShoeItemRow')
class ShoeItems extends Table {
  TextColumn get id => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get label => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get sizeSystem => text()();
  TextColumn get sizeValue => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Singleton row (id is always 0) holding the user's own foot
/// measurements, independent of any one brand (§12).
@DataClassName('FootProfileRow')
class FootProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  RealColumn get leftFootLengthCm => real().nullable()();
  RealColumn get rightFootLengthCm => real().nullable()();
  RealColumn get leftFootWidthCm => real().nullable()();
  RealColumn get rightFootWidthCm => real().nullable()();
  TextColumn get archNotes => text().nullable()();
  TextColumn get preferredSizeSystem => text().nullable()();
  TextColumn get preferredSizeValue => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
