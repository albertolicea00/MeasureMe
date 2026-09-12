import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/data/repositories/measurement_repository_impl.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/screens/measurements/measurement_history_screen.dart';

import 'test_helpers.dart';

Widget _wrap(AppDatabase db, String typeId) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: MeasurementHistoryScreen(typeId: typeId),
    ),
  );
}

void main() {
  testWidgets('shows an empty state when the type has no recorded history', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    setPhoneViewport(tester);

    await tester.pumpWidget(_wrap(db, 'chest'));
    await tester.pumpAndSettle();

    expect(find.text('Add a few measurements to start seeing your progress.'), findsOneWidget);
    expect(find.text('Add measurement'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('shows current/previous/change once two entries exist', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    setPhoneViewport(tester);
    final repo = MeasurementRepositoryImpl(db.measurementDao);
    await repo.addEntry(typeId: 'chest', valueCanonical: 100, timestamp: DateTime(2026, 8, 1));
    await repo.addEntry(typeId: 'chest', valueCanonical: 102, timestamp: DateTime(2026, 9, 12));

    await tester.pumpWidget(_wrap(db, 'chest'));
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('102 cm'), findsWidgets);
    expect(find.text('100 cm'), findsWidgets);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('a single entry shows current value but no chart yet', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    setPhoneViewport(tester);
    await MeasurementRepositoryImpl(db.measurementDao).addEntry(
      typeId: 'waist',
      valueCanonical: 84,
      timestamp: DateTime(2026, 9, 1),
    );

    await tester.pumpWidget(_wrap(db, 'waist'));
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Add one more measurement to see a chart.'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });
}
