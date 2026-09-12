import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'providers/notification_providers.dart';
import 'providers/profile_providers.dart';
import 'providers/repository_providers.dart';
import 'router/app_router.dart';

class MeasureMeApp extends ConsumerStatefulWidget {
  const MeasureMeApp({super.key});

  @override
  ConsumerState<MeasureMeApp> createState() => _MeasureMeAppState();
}

class _MeasureMeAppState extends ConsumerState<MeasureMeApp> {
  StreamSubscription<String>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    _tapSubscription = service.onReminderTapped.listen((reminderId) {
      appRouter.push('/session');
    });

    // Reschedule anything due/changed since the app last ran.
    final reminders = await ref.read(reminderRepositoryProvider).getAll();
    await service.reconcileAll(reminders);
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(profileStreamProvider).value?.themeMode;

    return MaterialApp.router(
      title: 'MeasureMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (themeMode) {
        null => ThemeMode.system,
        _ => ThemeMode.values.byName(themeMode.name),
      },
      routerConfig: appRouter,
    );
  }
}
