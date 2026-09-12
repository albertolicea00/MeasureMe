import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/measurement_tables.dart';

part 'measurement_dao.g.dart';

@DriftAccessor(tables: [MeasurementTypes, Measurements])
class MeasurementDao extends DatabaseAccessor<AppDatabase> with _$MeasurementDaoMixin {
  MeasurementDao(super.db);

  Stream<List<MeasurementTypeRow>> watchTypes() {
    return (select(measurementTypes)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<MeasurementTypeRow>> getTypes() {
    return (select(measurementTypes)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<void> insertType(MeasurementTypesCompanion type) {
    return into(measurementTypes).insertOnConflictUpdate(type);
  }

  Future<void> setTracked(String typeId, bool tracked) {
    return (update(measurementTypes)..where((t) => t.id.equals(typeId)))
        .write(MeasurementTypesCompanion(isTracked: Value(tracked)));
  }

  Future<void> setFavorite(String typeId, bool favorite) {
    return (update(measurementTypes)..where((t) => t.id.equals(typeId)))
        .write(MeasurementTypesCompanion(isFavorite: Value(favorite)));
  }

  Future<MeasurementRow?> latestFor(String typeId) {
    final query = select(measurements)
      ..where((m) => m.typeId.equals(typeId))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<MeasurementRow?> watchLatestFor(String typeId) {
    final query = select(measurements)
      ..where((m) => m.typeId.equals(typeId))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Stream<List<MeasurementRow>> watchHistory(String typeId) {
    final query = select(measurements)
      ..where((m) => m.typeId.equals(typeId))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)]);
    return query.watch();
  }

  Future<List<MeasurementRow>> getHistory(String typeId, {DateTime? since}) {
    final query = select(measurements)
      ..where((m) => since == null
          ? m.typeId.equals(typeId)
          : (m.typeId.equals(typeId) & m.timestamp.isBiggerOrEqualValue(since)))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)]);
    return query.get();
  }

  Future<int> insertEntry(MeasurementsCompanion entry) {
    return into(measurements).insert(entry);
  }

  Future<void> updateEntry(MeasurementsCompanion entry) {
    return update(measurements).replace(entry);
  }

  Future<void> deleteEntry(String id) {
    return (delete(measurements)..where((m) => m.id.equals(id))).go();
  }

  Future<DateTime?> mostRecentTimestamp() async {
    final query = select(measurements)
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.timestamp;
  }
}
