import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../database/app_database.dart';
import '../database/daos/goal_dao.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dao);

  final GoalDao _dao;
  static const _uuid = Uuid();

  Goal _toDomain(GoalRow row) {
    return Goal(
      id: row.id,
      measurementTypeId: row.measurementTypeId,
      targetValueCanonical: row.targetValueCanonical,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<Goal>> watchAll() => _dao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<Goal?> getFor(String measurementTypeId) async {
    final row = await _dao.getFor(measurementTypeId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Goal> upsert({
    required String measurementTypeId,
    required double targetValueCanonical,
    String? note,
  }) async {
    final existing = await _dao.getFor(measurementTypeId);
    final now = DateTime.now();
    final row = await _dao.upsert(GoalsCompanion(
      id: Value(existing?.id ?? _uuid.v4()),
      measurementTypeId: Value(measurementTypeId),
      targetValueCanonical: Value(targetValueCanonical),
      note: Value(note),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    ));
    return _toDomain(row);
  }

  @override
  Future<void> delete(String measurementTypeId) => _dao.deleteGoal(measurementTypeId);
}
