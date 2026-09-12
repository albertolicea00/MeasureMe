import '../entities/goal.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchAll();

  Future<Goal?> getFor(String measurementTypeId);

  /// Creates or replaces the goal for a measurement type (one active goal
  /// per type).
  Future<Goal> upsert({
    required String measurementTypeId,
    required double targetValueCanonical,
    String? note,
  });

  Future<void> delete(String measurementTypeId);
}
