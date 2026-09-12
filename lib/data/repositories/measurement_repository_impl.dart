import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/measurement_units.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../database/app_database.dart';
import '../database/daos/measurement_dao.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  MeasurementRepositoryImpl(this._dao);

  final MeasurementDao _dao;
  static const _uuid = Uuid();

  MeasurementCategory _categoryFromName(String name) {
    return MeasurementCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => MeasurementCategory.custom,
    );
  }

  CanonicalUnit _unitFromName(String name) {
    return CanonicalUnit.values.firstWhere((u) => u.name == name);
  }

  MeasurementSource _sourceFromName(String name) {
    return MeasurementSource.values.firstWhere(
      (s) => s.name == name,
      orElse: () => MeasurementSource.manual,
    );
  }

  MeasurementType _toDomainType(MeasurementTypeRow row) {
    return MeasurementType(
      id: row.id,
      displayName: row.displayName,
      category: _categoryFromName(row.category),
      canonicalUnit: _unitFromName(row.canonicalUnit),
      instructions: row.instructions,
      isCustom: row.isCustom,
      sortOrder: row.sortOrder,
    );
  }

  MeasurementEntry _toDomainEntry(MeasurementRow row) {
    return MeasurementEntry(
      id: row.id,
      typeId: row.typeId,
      valueCanonical: row.valueCanonical,
      unit: _unitFromName(row.unit),
      timestamp: row.timestamp,
      notes: row.notes,
      source: _sourceFromName(row.source),
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<MeasurementType>> watchTypes() {
    return _dao.watchTypes().map((rows) => rows.map(_toDomainType).toList());
  }

  @override
  Future<List<MeasurementType>> getTypes() async {
    final rows = await _dao.getTypes();
    return rows.map(_toDomainType).toList();
  }

  @override
  Future<void> addCustomType(MeasurementType type) {
    return _dao.insertType(MeasurementTypesCompanion.insert(
      id: type.id,
      category: type.category.name,
      displayName: type.displayName,
      canonicalUnit: type.canonicalUnit.name,
      instructions: Value(type.instructions),
      isCustom: const Value(true),
      sortOrder: Value(type.sortOrder),
    ));
  }

  @override
  Future<void> setTypeTracked(String typeId, bool tracked) => _dao.setTracked(typeId, tracked);

  @override
  Future<void> setTypeFavorite(String typeId, bool favorite) => _dao.setFavorite(typeId, favorite);

  @override
  Future<MeasurementEntry?> latestFor(String typeId) async {
    final row = await _dao.latestFor(typeId);
    return row == null ? null : _toDomainEntry(row);
  }

  @override
  Stream<MeasurementEntry?> watchLatestFor(String typeId) {
    return _dao.watchLatestFor(typeId).map((row) => row == null ? null : _toDomainEntry(row));
  }

  @override
  Stream<List<MeasurementEntry>> watchHistory(String typeId) {
    return _dao.watchHistory(typeId).map((rows) => rows.map(_toDomainEntry).toList());
  }

  @override
  Future<List<MeasurementEntry>> getHistory(String typeId, {DateTime? since}) async {
    final rows = await _dao.getHistory(typeId, since: since);
    return rows.map(_toDomainEntry).toList();
  }

  @override
  Future<MeasurementEntry> addEntry({
    required String typeId,
    required double valueCanonical,
    required DateTime timestamp,
    String? notes,
    MeasurementSource source = MeasurementSource.manual,
  }) async {
    final types = await _dao.getTypes();
    final type = types.firstWhere((t) => t.id == typeId);
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertEntry(MeasurementsCompanion.insert(
      id: id,
      typeId: typeId,
      valueCanonical: valueCanonical,
      unit: type.canonicalUnit,
      timestamp: timestamp,
      notes: Value(notes),
      source: Value(source.name),
      createdAt: Value(now),
    ));
    return MeasurementEntry(
      id: id,
      typeId: typeId,
      valueCanonical: valueCanonical,
      unit: _unitFromName(type.canonicalUnit),
      timestamp: timestamp,
      notes: notes,
      source: source,
      createdAt: now,
    );
  }

  @override
  Future<void> updateEntry(MeasurementEntry entry) {
    return _dao.updateEntry(MeasurementsCompanion(
      id: Value(entry.id),
      typeId: Value(entry.typeId),
      valueCanonical: Value(entry.valueCanonical),
      unit: Value(entry.unit.name),
      timestamp: Value(entry.timestamp),
      notes: Value(entry.notes),
      source: Value(entry.source.name),
      createdAt: Value(entry.createdAt),
    ));
  }

  @override
  Future<void> deleteEntry(String id) => _dao.deleteEntry(id);

  @override
  Future<DateTime?> mostRecentEntryTimestamp() => _dao.mostRecentTimestamp();
}
