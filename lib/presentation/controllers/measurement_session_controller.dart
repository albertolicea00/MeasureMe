import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/measurement_type.dart';
import '../../integrations/health/health_metric.dart';
import '../providers/health_providers.dart';
import '../providers/measurement_providers.dart';
import '../providers/notification_providers.dart';
import '../providers/repository_providers.dart';

/// Which health metrics failed to sync and why, keyed by measurement type
/// id — surfaced to the user rather than swallowed (§32).
typedef HealthSyncFailures = Map<String, String>;

/// Orchestrates a "Measurement Session" save (§24): writes only the
/// fields the user actually filled in, then reschedules reminders and
/// (if enabled) syncs supported metrics to the platform health store.
class MeasurementSessionController {
  MeasurementSessionController(this._ref);

  final Ref _ref;

  Future<HealthSyncFailures> saveSession({
    required Map<String, double> valuesByTypeIdCanonical,
    required DateTime timestamp,
    String? notes,
  }) async {
    final measurementRepo = _ref.read(measurementRepositoryProvider);
    final failures = <String, String>{};

    for (final entry in valuesByTypeIdCanonical.entries) {
      await measurementRepo.addEntry(
        typeId: entry.key,
        valueCanonical: entry.value,
        timestamp: timestamp,
        notes: notes,
      );
    }

    _ref.invalidate(mostRecentMeasurementTimestampProvider);

    final reminders = await _ref.read(reminderRepositoryProvider).getAll();
    await _ref.read(notificationServiceProvider).reconcileAll(reminders);

    final profile = await _ref.read(profileRepositoryProvider).getProfile();
    final healthMetricByType = {
      for (final metric in HealthMetric.values) metric.measurementTypeId: metric,
    };
    final shouldSyncApple = profile.appleHealthSyncEnabled;
    final shouldSyncHealthConnect = profile.healthConnectSyncEnabled;

    if (shouldSyncApple || shouldSyncHealthConnect) {
      final healthService = _ref.read(healthServiceProvider);
      for (final entry in valuesByTypeIdCanonical.entries) {
        final metric = healthMetricByType[entry.key];
        if (metric == null) continue;
        try {
          await healthService.writeSample(metric, entry.value, timestamp);
        } on HealthTypeUnsupportedException catch (e) {
          failures[entry.key] = e.message;
        } on HealthPermissionDeniedException catch (e) {
          failures[entry.key] = e.message;
        } on HealthUnavailableException catch (e) {
          failures[entry.key] = e.message;
        }
      }
    }

    return failures;
  }
}

final measurementSessionControllerProvider = Provider<MeasurementSessionController>((ref) {
  return MeasurementSessionController(ref);
});

/// Fields shown on the Measurement Session screen: the union of the
/// dashboard defaults and anything the user has already recorded at
/// least once, so returning users see their established routine.
final sessionFieldTypesProvider = FutureProvider<List<MeasurementType>>((ref) async {
  final allTypes = await ref.watch(measurementRepositoryProvider).getTypes();
  return allTypes.where((t) => t.isTracked).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
});
