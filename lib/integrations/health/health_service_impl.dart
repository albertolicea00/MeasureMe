import 'package:health/health.dart';

import '../../core/errors/app_exceptions.dart';
import 'health_metric.dart';
import 'health_service.dart';

/// Shared implementation on top of package:health, which wraps both
/// HealthKit (iOS) and Health Connect (Android) behind one plugin API.
/// [AppleHealthService] and [HealthConnectService] are thin,
/// platform-specific subclasses so the rest of the app can still depend
/// on distinct types per §17, even though both delegate to the same
/// plugin under the hood — that plugin choice is an implementation
/// detail, not something the domain/presentation layers know about.
abstract class PackageHealthService implements HealthService {
  PackageHealthService() {
    _health.configure();
  }

  final Health _health = Health();

  @override
  List<HealthMetric> get supportedMetrics => const [
        HealthMetric.weight,
        HealthMetric.height,
        HealthMetric.bodyFatPercentage,
      ];

  HealthDataType _dataTypeFor(HealthMetric metric) {
    switch (metric) {
      case HealthMetric.weight:
        return HealthDataType.WEIGHT;
      case HealthMetric.height:
        return HealthDataType.HEIGHT;
      case HealthMetric.bodyFatPercentage:
        return HealthDataType.BODY_FAT_PERCENTAGE;
    }
  }

  HealthDataUnit _unitFor(HealthMetric metric) {
    switch (metric) {
      case HealthMetric.weight:
        return HealthDataUnit.KILOGRAM;
      case HealthMetric.height:
        return HealthDataUnit.CENTIMETER;
      case HealthMetric.bodyFatPercentage:
        return HealthDataUnit.PERCENT;
    }
  }

  @override
  Future<HealthAuthorizationResult> requestAuthorization(List<HealthMetric> metrics) async {
    final supported = metrics.where(supportedMetrics.contains).toList();
    if (supported.isEmpty) return HealthAuthorizationResult.denied;

    final types = supported.map(_dataTypeFor).toList();
    final permissions = List.filled(types.length, HealthDataAccess.READ_WRITE);

    final granted = await _health.requestAuthorization(types, permissions: permissions);
    if (!granted) return HealthAuthorizationResult.denied;
    return supported.length == metrics.length
        ? HealthAuthorizationResult.granted
        : HealthAuthorizationResult.partiallyGranted;
  }

  @override
  Future<bool> hasPermission(HealthMetric metric) async {
    if (!supportedMetrics.contains(metric)) return false;
    final has = await _health.hasPermissions(
      [_dataTypeFor(metric)],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    return has ?? false;
  }

  @override
  Future<List<HealthSample>> readSamples(HealthMetric metric, {DateTime? since}) async {
    if (!supportedMetrics.contains(metric)) {
      throw HealthTypeUnsupportedException(
        '${metric.label} cannot currently be read from $platformName.',
      );
    }
    final points = await _health.getHealthDataFromTypes(
      types: [_dataTypeFor(metric)],
      startTime: since ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      endTime: DateTime.now(),
    );

    final samples = <HealthSample>[];
    for (final point in points) {
      final value = point.value;
      if (value is NumericHealthValue) {
        samples.add(HealthSample(
          metric: metric,
          valueCanonical: value.numericValue.toDouble(),
          timestamp: point.dateFrom,
        ));
      }
    }
    return samples;
  }

  @override
  Future<void> writeSample(HealthMetric metric, double valueCanonical, DateTime timestamp) async {
    if (!supportedMetrics.contains(metric)) {
      throw HealthTypeUnsupportedException(
        '${metric.label} cannot currently be synchronized with $platformName.',
      );
    }
    final ok = await _health.writeHealthData(
      value: valueCanonical,
      unit: _unitFor(metric),
      type: _dataTypeFor(metric),
      startTime: timestamp,
      endTime: timestamp,
      recordingMethod: RecordingMethod.manual,
    );
    if (!ok) {
      throw HealthPermissionDeniedException(
        'Could not write ${metric.label} to $platformName. Check that permission was granted.',
      );
    }
  }
}
