import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/core/constants/measurement_units.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/domain/entities/measurement_type.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/providers/repository_providers.dart';
import 'package:measure_me/presentation/widgets/forms/measurement_entry_form_sheet.dart';

void main() {
  testWidgets('saving a new measurement entry persists it via the repository', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: MeasurementEntryFormSheet(
              type: MeasurementTypeCatalog.chest,
              unitSystem: UnitSystem.metric,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chest'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Value'), '102.5');
    await tester.tap(find.text('Save measurement'));
    await tester.pumpAndSettle();

    final history = await db.measurementDao.getHistory('chest');
    expect(history, hasLength(1));
    expect(history.single.valueCanonical, 102.5);
  });

  testWidgets('entering nothing and saving shows a validation snackbar instead of saving', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: MeasurementEntryFormSheet(
              type: MeasurementTypeCatalog.weight,
              unitSystem: UnitSystem.metric,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save measurement'));
    await tester.pump();

    expect(find.text('Enter a valid number.'), findsOneWidget);
    final history = await db.measurementDao.getHistory('weight');
    expect(history, isEmpty);
  });

  testWidgets('editing an existing entry updates that row instead of inserting a new one', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)])
        .read(measurementRepositoryProvider);
    final existing = await repo.addEntry(
      typeId: 'waist',
      valueCanonical: 90,
      timestamp: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: MeasurementEntryFormSheet(
              type: MeasurementTypeCatalog.waist,
              unitSystem: UnitSystem.metric,
              existing: existing,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Value'), '88');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final history = await db.measurementDao.getHistory('waist');
    expect(history, hasLength(1));
    expect(history.single.valueCanonical, 88.0);
  });
}
