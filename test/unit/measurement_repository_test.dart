import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/core/constants/measurement_units.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/data/repositories/measurement_repository_impl.dart';
import 'package:measure_me/domain/entities/measurement_entry.dart';
import 'package:measure_me/domain/entities/measurement_type.dart';

void main() {
  late AppDatabase db;
  late MeasurementRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepositoryImpl(db.measurementDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('MeasurementRepositoryImpl', () {
    test('built-in catalog is seeded on first run', () async {
      final types = await repository.getTypes();
      expect(types.map((t) => t.id), contains('weight'));
      expect(types.map((t) => t.id), contains('chest'));
      expect(types.length, greaterThanOrEqualTo(17));
    });

    test('addEntry stores a value using the type\'s canonical unit', () async {
      final entry = await repository.addEntry(
        typeId: 'weight',
        valueCanonical: 82.4,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(entry.unit, CanonicalUnit.kilograms);
      expect(entry.valueCanonical, 82.4);
      expect(entry.source, MeasurementSource.manual);
    });

    test('recording a new value never overwrites the previous one', () async {
      await repository.addEntry(
        typeId: 'chest',
        valueCanonical: 100,
        timestamp: DateTime(2026, 9, 1),
      );
      await repository.addEntry(
        typeId: 'chest',
        valueCanonical: 102,
        timestamp: DateTime(2026, 9, 12),
      );

      final history = await repository.getHistory('chest');
      expect(history, hasLength(2));
      expect(history.map((e) => e.valueCanonical), containsAll([100.0, 102.0]));
    });

    test('latestFor returns the most recently timestamped entry, not the most recently inserted', () async {
      // Insert the older-dated entry second, to prove ordering is by
      // timestamp and not insertion order.
      await repository.addEntry(typeId: 'weight', valueCanonical: 80, timestamp: DateTime(2026, 6, 1));
      await repository.addEntry(typeId: 'weight', valueCanonical: 78, timestamp: DateTime(2026, 3, 1));

      final latest = await repository.latestFor('weight');
      expect(latest!.valueCanonical, 80);
    });

    test('latestFor returns null when nothing has been recorded', () async {
      expect(await repository.latestFor('waist'), isNull);
    });

    test('updateEntry changes that specific historical row in place', () async {
      final entry = await repository.addEntry(
        typeId: 'waist',
        valueCanonical: 90,
        timestamp: DateTime(2026, 1, 1),
        notes: 'morning',
      );
      await repository.updateEntry(entry.copyWith(valueCanonical: 89.5, notes: 'evening'));

      final updated = await repository.latestFor('waist');
      expect(updated!.valueCanonical, 89.5);
      expect(updated.notes, 'evening');
    });

    test('deleteEntry removes only that entry', () async {
      final first = await repository.addEntry(typeId: 'hips', valueCanonical: 95, timestamp: DateTime(2026, 1, 1));
      await repository.addEntry(typeId: 'hips', valueCanonical: 94, timestamp: DateTime(2026, 2, 1));

      await repository.deleteEntry(first.id);

      final history = await repository.getHistory('hips');
      expect(history, hasLength(1));
      expect(history.single.valueCanonical, 94);
    });

    test('setTypeTracked and setTypeFavorite persist and are reflected in getTypes', () async {
      await repository.setTypeTracked('calf_left', false);
      await repository.setTypeFavorite('waist', true);

      final types = await repository.getTypes();
      expect(types.firstWhere((t) => t.id == 'calf_left').isTracked, isFalse);
      expect(types.firstWhere((t) => t.id == 'waist').isFavorite, isTrue);
    });

    test('mostRecentEntryTimestamp reflects the newest entry across all types', () async {
      expect(await repository.mostRecentEntryTimestamp(), isNull);

      await repository.addEntry(typeId: 'weight', valueCanonical: 80, timestamp: DateTime(2026, 1, 1));
      await repository.addEntry(typeId: 'chest', valueCanonical: 100, timestamp: DateTime(2026, 5, 1));

      expect(await repository.mostRecentEntryTimestamp(), DateTime(2026, 5, 1));
    });

    test('addCustomType lets a new measurement type be recorded against immediately', () async {
      await repository.addCustomType(const MeasurementType(
        id: 'wrist',
        displayName: 'Wrist',
        category: MeasurementCategory.custom,
        canonicalUnit: CanonicalUnit.centimeters,
        isCustom: true,
      ));
      final entry = await repository.addEntry(
        typeId: 'wrist',
        valueCanonical: 16.5,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(entry.valueCanonical, 16.5);

      final types = await repository.getTypes();
      expect(types.firstWhere((t) => t.id == 'wrist').isCustom, isTrue);
    });
  });
}
