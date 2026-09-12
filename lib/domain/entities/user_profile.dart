import '../../core/constants/measurement_units.dart';

enum AppThemeMode { light, dark, system }

/// Singleton profile + app settings row (§18, §21, §31). There is only
/// ever one [UserProfile] in the database.
class UserProfile {
  final String? nickname;
  final int? age;
  final UnitSystem unitSystem;
  final AppThemeMode themeMode;
  final bool onboardingComplete;
  final bool appleHealthSyncEnabled;
  final bool healthConnectSyncEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    this.nickname,
    this.age,
    this.unitSystem = UnitSystem.metric,
    this.themeMode = AppThemeMode.system,
    this.onboardingComplete = false,
    this.appleHealthSyncEnabled = false,
    this.healthConnectSyncEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? nickname,
    int? age,
    UnitSystem? unitSystem,
    AppThemeMode? themeMode,
    bool? onboardingComplete,
    bool? appleHealthSyncEnabled,
    bool? healthConnectSyncEnabled,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      unitSystem: unitSystem ?? this.unitSystem,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      appleHealthSyncEnabled: appleHealthSyncEnabled ?? this.appleHealthSyncEnabled,
      healthConnectSyncEnabled: healthConnectSyncEnabled ?? this.healthConnectSyncEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
