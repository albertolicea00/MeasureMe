import '../../core/constants/measurement_units.dart';

/// Where a recorded measurement value came from. Kept explicit so the UI
/// can always distinguish user-entered data from data synchronized in from
/// a platform health store (§17 / implementation rule 17).
enum MeasurementSource {
  manual,
  appleHealth,
  healthConnect,
}

/// A single historical data point for a [MeasurementType]. Measurements are
/// never overwritten in place — every entry is its own row, so history is
/// always preserved (§6).
class MeasurementEntry {
  final String id;
  final String typeId;
  final double valueCanonical;
  final CanonicalUnit unit;
  final DateTime timestamp;
  final String? notes;
  final MeasurementSource source;
  final DateTime createdAt;

  const MeasurementEntry({
    required this.id,
    required this.typeId,
    required this.valueCanonical,
    required this.unit,
    required this.timestamp,
    this.notes,
    this.source = MeasurementSource.manual,
    required this.createdAt,
  });

  MeasurementEntry copyWith({
    double? valueCanonical,
    DateTime? timestamp,
    String? notes,
    MeasurementSource? source,
  }) {
    return MeasurementEntry(
      id: id,
      typeId: typeId,
      valueCanonical: valueCanonical ?? this.valueCanonical,
      unit: unit,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      createdAt: createdAt,
    );
  }
}
