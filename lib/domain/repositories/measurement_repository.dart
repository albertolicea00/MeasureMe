import '../entities/measurement_entry.dart';
import '../entities/measurement_type.dart';

abstract class MeasurementRepository {
  /// All tracked measurement types, built-in and custom, sorted for display.
  Stream<List<MeasurementType>> watchTypes();

  Future<List<MeasurementType>> getTypes();

  Future<void> addCustomType(MeasurementType type);

  Future<void> setTypeTracked(String typeId, bool tracked);

  Future<void> setTypeFavorite(String typeId, bool favorite);

  /// The most recent entry for [typeId], or null if never recorded.
  Future<MeasurementEntry?> latestFor(String typeId);

  Stream<MeasurementEntry?> watchLatestFor(String typeId);

  /// Full history for [typeId], newest first.
  Stream<List<MeasurementEntry>> watchHistory(String typeId);

  Future<List<MeasurementEntry>> getHistory(String typeId, {DateTime? since});

  Future<MeasurementEntry> addEntry({
    required String typeId,
    required double valueCanonical,
    required DateTime timestamp,
    String? notes,
    MeasurementSource source = MeasurementSource.manual,
  });

  Future<void> updateEntry(MeasurementEntry entry);

  Future<void> deleteEntry(String id);

  /// The most recent timestamp across all measurement entries, used to
  /// drive "last measured N days ago" copy on the dashboard.
  Future<DateTime?> mostRecentEntryTimestamp();
}
