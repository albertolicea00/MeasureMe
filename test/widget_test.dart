// Top-level smoke test for the onboarding flow, the very first thing a
// fresh install shows. Feature-specific widget tests for the four areas
// called out in the spec (measurement entry, dashboard, measurement
// history, clothing size entry) live under test/widget/.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('onboarding shows the intro screens before collecting profile info', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Know your measurements.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('completing onboarding saves the profile and unit preference', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // The screen calls context.go('/home') (go_router) when finished, so a
    // real router ancestor is needed, not just a bare MaterialApp.
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: SizedBox())),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('A little about you'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nickname (optional)'), 'Alex');
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    final profile = await db.profileDao.getProfile();
    expect(profile.onboardingComplete, isTrue);
    expect(profile.nickname, 'Alex');
  });
}
