import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/data/repositories/clothing_repository_impl.dart';
import 'package:measure_me/domain/entities/clothing_item.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/screens/clothing/clothing_item_edit_screen.dart';

import 'test_helpers.dart';

/// The screen calls `context.pop()` on save/delete (go_router), so the test
/// needs a real router ancestor, not just a bare [MaterialApp]. A base route
/// gives the pushed edit route somewhere to pop back to, matching how it's
/// actually reached in the app (pushed from the clothing list screen).
Future<GoRouter> _pumpEditScreen(WidgetTester tester, AppDatabase db, {String? itemId}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: SizedBox())),
      GoRoute(path: '/edit', builder: (context, state) => ClothingItemEditScreen(itemId: itemId)),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  router.push('/edit');
  await tester.pumpAndSettle();

  return router;
}

void main() {
  testWidgets('saving a new clothing size persists brand, size, and category', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await _pumpEditScreen(tester, db);

    expect(find.text('Add clothing size'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Brand (optional)'), 'SuitSupply');
    await tester.enterText(find.widgetWithText(TextField, 'Size'), '42R');
    // The default category's measurement fields push the Save button below
    // the fold; a real user would scroll, so the test does too.
    await tester.scrollUntilVisible(find.text('Save'), 300);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final items = await ClothingRepositoryImpl(db.clothingDao).search();
    expect(items, hasLength(1));
    expect(items.single.brand, 'SuitSupply');
    expect(items.single.size, '42R');

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('rejects saving without a size', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await _pumpEditScreen(tester, db);

    await tester.scrollUntilVisible(find.text('Save'), 300);
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Enter a size.'), findsOneWidget);
    final items = await ClothingRepositoryImpl(db.clothingDao).search();
    expect(items, isEmpty);

    await disposeWidgetTreeCleanly(tester);
  });

  testWidgets('editing an existing item pre-fills its fields and can be deleted', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ClothingRepositoryImpl(db.clothingDao);
    final now = DateTime.now();
    final existing = await repo.add(ClothingItem(
      id: '',
      category: ClothingCategory.pants,
      brand: "Levi's",
      size: '34x32',
      createdAt: now,
      updatedAt: now,
    ));

    await _pumpEditScreen(tester, db, itemId: existing.id);

    expect(find.text('Edit clothing size'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Brand (optional)'), findsOneWidget);
    expect(find.text('34x32'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(await repo.search(), isEmpty);

    await disposeWidgetTreeCleanly(tester);
  });
}
