/// A user-defined target for a measurement type (§26). This is never a
/// medical recommendation — just a number the user chose for themselves.
class Goal {
  final String id;
  final String measurementTypeId;
  final double targetValueCanonical;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.measurementTypeId,
    required this.targetValueCanonical,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Goal copyWith({double? targetValueCanonical, String? note}) {
    return Goal(
      id: id,
      measurementTypeId: measurementTypeId,
      targetValueCanonical: targetValueCanonical ?? this.targetValueCanonical,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
