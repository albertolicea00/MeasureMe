import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import 'repository_providers.dart';

final measurementTypesProvider = StreamProvider<List<MeasurementType>>((ref) {
  return ref.watch(measurementRepositoryProvider).watchTypes();
});

final latestMeasurementProvider =
    StreamProvider.family<MeasurementEntry?, String>((ref, typeId) {
  return ref.watch(measurementRepositoryProvider).watchLatestFor(typeId);
});

final measurementHistoryProvider =
    StreamProvider.family<List<MeasurementEntry>, String>((ref, typeId) {
  return ref.watch(measurementRepositoryProvider).watchHistory(typeId);
});

/// Recomputed on demand; controllers that record a new entry call
/// `ref.invalidate(mostRecentMeasurementTimestampProvider)` afterwards so
/// dashboard copy like "last measured N days ago" stays current.
final mostRecentMeasurementTimestampProvider = FutureProvider<DateTime?>((ref) {
  return ref.watch(measurementRepositoryProvider).mostRecentEntryTimestamp();
});
