import 'package:drift/drift.dart';

/// A clothing size/sizing record — serves as both "preferred size for a
/// brand" (§11) and "an item I own" (§13); see [ClothingItem] entity.
@DataClassName('ClothingItemRow')
class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get itemName => text().nullable()();
  TextColumn get size => text()();
  TextColumn get fit => text().nullable()();
  TextColumn get measurementsJson => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
