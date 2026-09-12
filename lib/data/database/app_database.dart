import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/measurement_type.dart';
import 'daos/clothing_dao.dart';
import 'daos/goal_dao.dart';
import 'daos/measurement_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/shoe_dao.dart';
import 'tables/clothing_tables.dart';
import 'tables/goal_tables.dart';
import 'tables/measurement_tables.dart';
import 'tables/reminder_tables.dart';
import 'tables/shoe_tables.dart';
import 'tables/user_profile_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MeasurementTypes,
    Measurements,
    ClothingItems,
    ShoeItems,
    FootProfiles,
    Reminders,
    Goals,
    UserProfileTable,
  ],
  daos: [MeasurementDao, ClothingDao, ShoeDao, ReminderDao, GoalDao, ProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults(this);
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'measureme.sqlite'));
      return NativeDatabase.createInBackground(file, setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      });
    });
  }
}

/// Seeds the built-in measurement type catalog, an empty profile row, and
/// the default monthly reminder (§14, §35). Runs once, on first launch.
Future<void> _seedDefaults(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now();

  await db.batch((batch) {
    batch.insertAll(
      db.measurementTypes,
      MeasurementTypeCatalog.builtIns
          .map((type) => MeasurementTypesCompanion.insert(
                id: type.id,
                category: type.category.name,
                displayName: type.displayName,
                canonicalUnit: type.canonicalUnit.name,
                instructions: Value(type.instructions),
                sortOrder: Value(type.sortOrder),
              ))
          .toList(),
    );
  });

  await db.into(db.userProfileTable).insert(
        UserProfileTableCompanion.insert(
          id: const Value(0),
          createdAt: now,
          updatedAt: now,
        ),
      );

  await db.into(db.reminders).insert(
        RemindersCompanion.insert(
          id: uuid.v4(),
          frequency: 'monthly',
          hour: 9,
          minute: 0,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}
