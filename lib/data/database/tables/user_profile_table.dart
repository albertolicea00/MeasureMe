import 'package:drift/drift.dart';

/// Singleton row (id is always 0) for profile + app-wide settings (§18,
/// §21, §31).
@DataClassName('UserProfileRow')
class UserProfileTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get nickname => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get unitSystem => text().withDefault(const Constant('metric'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();
  BoolColumn get appleHealthSyncEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get healthConnectSyncEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
