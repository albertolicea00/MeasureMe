import '../entities/reminder.dart';

abstract class ReminderRepository {
  Stream<List<Reminder>> watchAll();

  Future<List<Reminder>> getAll();

  Future<Reminder> add(Reminder reminder);

  Future<void> update(Reminder reminder);

  Future<void> delete(String id);

  Future<void> markFired(String id, DateTime firedAt);
}
