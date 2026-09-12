import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/reminder.dart';
import '../../../integrations/notifications/reminder_scheduler.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/reminder_providers.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/empty_states/empty_state.dart';
import 'reminder_edit_sheet.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final typesAsync = ref.watch(measurementTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none,
              message: 'No reminders set. We\'ll never nudge you unless you ask.',
              actionLabel: 'Add reminder',
              onAction: () => ReminderEditSheet.show(context),
            );
          }
          final typeNames = {for (final t in typesAsync.value ?? []) t.id: t.displayName};

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final title = reminder.measurementTypeId == null
                  ? 'General measurement update'
                  : (typeNames[reminder.measurementTypeId] ?? 'Measurement update');
              final next = ReminderScheduler.nextOccurrence(reminder, from: DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => ReminderEditSheet.show(context, existing: reminder),
                  title: Text(title),
                  subtitle: Text(
                    '${reminder.frequency.label} · ${TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context)}'
                    '${reminder.enabled ? ' · Next ${next.month}/${next.day}' : ''}',
                  ),
                  trailing: Switch(
                    value: reminder.enabled,
                    onChanged: (value) async {
                      final updated = reminder.copyWith(enabled: value);
                      await ref.read(reminderRepositoryProvider).update(updated);
                      final notificationService = ref.read(notificationServiceProvider);
                      if (value) {
                        await notificationService.scheduleReminder(updated);
                      } else {
                        await notificationService.cancelReminder(updated.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'remindersFab',
        onPressed: () => ReminderEditSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
