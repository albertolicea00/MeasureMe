import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../database/app_database.dart';
import '../database/daos/reminder_dao.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._dao);

  final ReminderDao _dao;
  static const _uuid = Uuid();

  Reminder _toDomain(ReminderRow row) {
    return Reminder(
      id: row.id,
      measurementTypeId: row.measurementTypeId,
      frequency: ReminderFrequency.values.firstWhere((f) => f.name == row.frequency),
      customIntervalDays: row.customIntervalDays,
      hour: row.hour,
      minute: row.minute,
      enabled: row.enabled,
      lastFiredAt: row.lastFiredAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  RemindersCompanion _toCompanion(Reminder reminder) {
    return RemindersCompanion(
      id: Value(reminder.id),
      measurementTypeId: Value(reminder.measurementTypeId),
      frequency: Value(reminder.frequency.name),
      customIntervalDays: Value(reminder.customIntervalDays),
      hour: Value(reminder.hour),
      minute: Value(reminder.minute),
      enabled: Value(reminder.enabled),
      lastFiredAt: Value(reminder.lastFiredAt),
      createdAt: Value(reminder.createdAt),
      updatedAt: Value(reminder.updatedAt),
    );
  }

  @override
  Stream<List<Reminder>> watchAll() => _dao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<Reminder>> getAll() async => (await _dao.getAll()).map(_toDomain).toList();

  @override
  Future<Reminder> add(Reminder reminder) async {
    final now = DateTime.now();
    final withId = Reminder(
      id: _uuid.v4(),
      measurementTypeId: reminder.measurementTypeId,
      frequency: reminder.frequency,
      customIntervalDays: reminder.customIntervalDays,
      hour: reminder.hour,
      minute: reminder.minute,
      enabled: reminder.enabled,
      createdAt: now,
      updatedAt: now,
    );
    final row = await _dao.insertReminder(_toCompanion(withId));
    return _toDomain(row);
  }

  @override
  Future<void> update(Reminder reminder) => _dao.updateReminder(_toCompanion(reminder));

  @override
  Future<void> delete(String id) => _dao.deleteReminder(id);

  @override
  Future<void> markFired(String id, DateTime firedAt) => _dao.markFired(id, firedAt);
}
