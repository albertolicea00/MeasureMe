import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/data/repositories/measurement_repository_impl.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/screens/home/home_dashboard_screen.dart';

import 'test_helpers.dart';

Widget _wrap(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(body: HomeDashboardScreen(onGoToTab: (_) {})),
    ),
  );
}

void main() {
  testWidgets('shows "Add measurement" empty state for every card when nothing is recorded', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Add measurement'), findsWidgets);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('shows the reminder card prompting to record a first measurement', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('You haven\'t recorded any measurements yet.'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('shows quick actions for the core flows', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Add measurement'), findsWidgets);
    expect(find.text('View progress'), findsOneWidget);
    expect(find.text('Clothing & suits'), findsOneWidget);
    expect(find.text('Shoe sizes'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('a recorded weight value replaces its empty state with the formatted value', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await MeasurementRepositoryImpl(db.measurementDao).addEntry(
      typeId: 'weight',
      valueCanonical: 82.4,
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.textContaining('82.4'), findsOneWidget);

    await disposeWidgetTreeCleanly(tester);
  });
}
