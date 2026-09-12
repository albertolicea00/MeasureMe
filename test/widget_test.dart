// Top-level smoke test: the real app widget (routing, theming, and the
// startup gate all wired together) boots to onboarding for a fresh
// install without throwing. Feature-specific widget tests live under
// test/widget/.
//
// The database and notification plugin are overridden with in-memory /
// fake implementations because `path_provider` and
// `flutter_local_notifications` have no platform channel available under
// plain `flutter_test`.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/data/database/app_database.dart';
import 'package:measure_me/domain/entities/reminder.dart';
import 'package:measure_me/integrations/notifications/notification_service.dart';
import 'package:measure_me/presentation/app.dart';
import 'package:measure_me/presentation/providers/database_provider.dart';
import 'package:measure_me/presentation/providers/notification_providers.dart';

class _FakeNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleReminder(Reminder reminder) async {}

  @override
  Future<void> cancelReminder(String reminderId) async {}

  @override
  Future<void> reconcileAll(List<Reminder> reminders) async {}

  @override
  Stream<String> get onReminderTapped => const Stream.empty();
}

void main() {
  testWidgets('a fresh install boots to the onboarding flow', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
        ],
        child: const MeasureMeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Know your measurements.'), findsOneWidget);
  });
}
