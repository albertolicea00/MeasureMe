import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [UserProfileTable])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<UserProfileRow> watchProfile() {
    return (select(userProfileTable)..where((t) => t.id.equals(0)))
        .watchSingleOrNull()
        .map((row) => row ?? _default());
  }

  Future<UserProfileRow> getProfile() async {
    final row = await (select(userProfileTable)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row ?? _default();
  }

  UserProfileRow _default() {
    final now = DateTime.now();
    return UserProfileRow(
      id: 0,
      unitSystem: 'metric',
      themeMode: 'system',
      onboardingComplete: false,
      appleHealthSyncEnabled: false,
      healthConnectSyncEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> upsertProfile(UserProfileTableCompanion profile) {
    return into(userProfileTable).insertOnConflictUpdate(profile);
  }
}
