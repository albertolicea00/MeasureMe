import '../../core/errors/app_exceptions.dart';
import 'health_metric.dart';
import 'health_service.dart';

/// Used on platforms with no health store integration at all (desktop,
/// web). Fails clearly rather than pretending to sync (§32).
class UnsupportedHealthService implements HealthService {
  @override
  String get platformName => 'Health sync';

  @override
  List<HealthMetric> get supportedMetrics => const [];

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<HealthAuthorizationResult> requestAuthorization(List<HealthMetric> metrics) async {
    return HealthAuthorizationResult.denied;
  }

  @override
  Future<bool> hasPermission(HealthMetric metric) async => false;

  @override
  Future<List<HealthSample>> readSamples(HealthMetric metric, {DateTime? since}) {
    throw const HealthUnavailableException('Health sync is not available on this platform.');
  }

  @override
  Future<void> writeSample(HealthMetric metric, double valueCanonical, DateTime timestamp) {
    throw const HealthUnavailableException('Health sync is not available on this platform.');
  }
}
