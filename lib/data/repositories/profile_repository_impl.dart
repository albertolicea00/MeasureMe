import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/measurement_units.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../database/app_database.dart';
import '../database/daos/profile_dao.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db, this._dao);

  final AppDatabase _db;
  final ProfileDao _dao;

  UserProfile _toDomain(UserProfileRow row) {
    return UserProfile(
      nickname: row.nickname,
      age: row.age,
      unitSystem: UnitSystem.values.firstWhere((u) => u.name == row.unitSystem),
      themeMode: AppThemeMode.values.firstWhere((t) => t.name == row.themeMode),
      onboardingComplete: row.onboardingComplete,
      appleHealthSyncEnabled: row.appleHealthSyncEnabled,
      healthConnectSyncEnabled: row.healthConnectSyncEnabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<UserProfile> watchProfile() => _dao.watchProfile().map(_toDomain);

  @override
  Future<UserProfile> getProfile() async => _toDomain(await _dao.getProfile());

  @override
  Future<void> updateProfile(UserProfile profile) {
    return _dao.upsertProfile(UserProfileTableCompanion(
      id: const Value(0),
      nickname: Value(profile.nickname),
      age: Value(profile.age),
      unitSystem: Value(profile.unitSystem.name),
      themeMode: Value(profile.themeMode.name),
      onboardingComplete: Value(profile.onboardingComplete),
      appleHealthSyncEnabled: Value(profile.appleHealthSyncEnabled),
      healthConnectSyncEnabled: Value(profile.healthConnectSyncEnabled),
      createdAt: Value(profile.createdAt),
      updatedAt: Value(profile.updatedAt),
    ));
  }

  @override
  Future<void> deleteAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.measurements).go();
      await _db.delete(_db.clothingItems).go();
      await _db.delete(_db.shoeItems).go();
      await _db.delete(_db.footProfiles).go();
      await _db.delete(_db.reminders).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.measurementTypes).go();
      await _db.delete(_db.userProfileTable).go();

      final now = DateTime.now();
      await _db.batch((batch) {
        batch.insertAll(
          _db.measurementTypes,
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

      await _db.into(_db.userProfileTable).insert(
            UserProfileTableCompanion.insert(
              id: const Value(0),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.reminders).insert(
            RemindersCompanion.insert(
              id: const Uuid().v4(),
              frequency: 'monthly',
              hour: 9,
              minute: 0,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    });
  }
}
