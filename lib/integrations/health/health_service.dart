import 'health_metric.dart';

/// A single sample read back from a platform health store. Values are
/// always in this app's canonical units (kg / cm / percent).
class HealthSample {
  final HealthMetric metric;
  final double valueCanonical;
  final DateTime timestamp;

  const HealthSample({
    required this.metric,
    required this.valueCanonical,
    required this.timestamp,
  });
}

enum HealthAuthorizationResult { granted, denied, partiallyGranted }

/// Platform-agnostic contract for syncing with a device health store.
///
/// The rest of the app talks to this interface only — never to HealthKit
/// or Health Connect APIs directly (§17). [AppleHealthService] and
/// [HealthConnectService] are the two concrete implementations; both are
/// backed by the `health` plugin, which wraps HealthKit and Health Connect
/// respectively, but each reports its own platform's real capabilities
/// rather than a shared lowest-common-denominator list.
abstract class HealthService {
  /// Human-readable platform name, e.g. "Apple Health" or "Health Connect".
  String get platformName;

  /// Whether the underlying health store exists on this device at all
  /// (e.g. Health Connect may not be installed on older Android builds).
  Future<bool> isAvailable();

  /// Metrics this platform can *technically* read/write. A metric being
  /// absent here means the app will not attempt to sync it and will say
  /// so explicitly in the UI, rather than silently failing (§15, §16).
  List<HealthMetric> get supportedMetrics;

  /// Requests read+write authorization for [metrics]. Only ever called
  /// when the user explicitly opts in (§33) — never at app launch.
  Future<HealthAuthorizationResult> requestAuthorization(List<HealthMetric> metrics);

  /// Whether MeasureMe currently holds permission for [metric]. On iOS,
  /// HealthKit does not reveal read-denial state precisely; this reflects
  /// what the app was told at the most recent authorization request.
  Future<bool> hasPermission(HealthMetric metric);

  Future<List<HealthSample>> readSamples(HealthMetric metric, {DateTime? since});

  Future<void> writeSample(HealthMetric metric, double valueCanonical, DateTime timestamp);
}
