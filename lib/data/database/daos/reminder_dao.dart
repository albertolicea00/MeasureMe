import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reminder_tables.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<ReminderRow>> watchAll() {
    return (select(reminders)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
  }

  Future<List<ReminderRow>> getAll() {
    return (select(reminders)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  Future<ReminderRow> insertReminder(RemindersCompanion reminder) {
    return into(reminders).insertReturning(reminder);
  }

  Future<void> updateReminder(RemindersCompanion reminder) {
    return update(reminders).replace(reminder);
  }

  Future<void> deleteReminder(String id) {
    return (delete(reminders)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markFired(String id, DateTime firedAt) {
    return (update(reminders)..where((t) => t.id.equals(id)))
        .write(RemindersCompanion(lastFiredAt: Value(firedAt)));
  }
}
