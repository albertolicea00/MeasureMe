import 'health_service_impl.dart';

/// HealthKit-backed [HealthService] for iOS. Requires the HealthKit
/// capability and `NSHealthShareUsageDescription` /
/// `NSHealthUpdateUsageDescription` entries in Info.plist — see README.
class AppleHealthService extends PackageHealthService {
  @override
  String get platformName => 'Apple Health';

  @override
  Future<bool> isAvailable() async {
    // HealthKit exists on every iOS device MeasureMe supports (iOS 15+,
    // per the health plugin's minimum), so availability is implicit —
    // there is nothing to install, unlike Health Connect on Android.
    return true;
  }
}
