import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile> watchProfile();

  Future<UserProfile> getProfile();

  Future<void> updateProfile(UserProfile profile);

  /// Deletes every row in every table and recreates the built-in
  /// measurement type catalog and default reminder (§22 — explicit,
  /// user-triggered full data deletion).
  Future<void> deleteAllData();
}
