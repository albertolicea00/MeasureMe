import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/goal_tables.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Stream<List<GoalRow>> watchAll() => select(goals).watch();

  Future<GoalRow?> getFor(String measurementTypeId) {
    return (select(goals)..where((g) => g.measurementTypeId.equals(measurementTypeId)))
        .getSingleOrNull();
  }

  Future<GoalRow> upsert(GoalsCompanion goal) async {
    await into(goals).insertOnConflictUpdate(goal);
    return (await getFor(goal.measurementTypeId.value))!;
  }

  Future<void> deleteGoal(String measurementTypeId) {
    return (delete(goals)..where((g) => g.measurementTypeId.equals(measurementTypeId))).go();
  }
}
