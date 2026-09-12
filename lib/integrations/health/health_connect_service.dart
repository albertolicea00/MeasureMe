import 'package:health/health.dart';

import 'health_service_impl.dart';

/// Health Connect-backed [HealthService] for Android. Health Connect is a
/// separate app the user may not have installed — [isAvailable] reflects
/// that honestly instead of assuming it exists (§16).
class HealthConnectService extends PackageHealthService {
  @override
  String get platformName => 'Health Connect';

  @override
  Future<bool> isAvailable() async {
    return Health().isHealthConnectAvailable();
  }

  /// Opens the Play Store listing (or in-place update flow) for Health
  /// Connect. Call this when [isAvailable] is false and the user has
  /// asked to connect.
  Future<void> promptInstall() => Health().installHealthConnect();
}
