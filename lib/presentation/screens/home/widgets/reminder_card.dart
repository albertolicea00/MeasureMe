import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/reminder.dart';
import '../../../../integrations/notifications/reminder_scheduler.dart';
import '../../../providers/measurement_providers.dart';
import '../../../providers/reminder_providers.dart';

class ReminderCard extends ConsumerWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final lastMeasuredAsync = ref.watch(mostRecentMeasurementTimestampProvider);

    return remindersAsync.when(
      data: (reminders) {
        final enabled = reminders.where((r) => r.enabled).toList();
        if (enabled.isEmpty) return const SizedBox.shrink();

        Reminder soonest = enabled.first;
        var soonestDate = ReminderScheduler.nextOccurrence(soonest, from: DateTime.now());
        for (final r in enabled.skip(1)) {
          final next = ReminderScheduler.nextOccurrence(r, from: DateTime.now());
          if (next.isBefore(soonestDate)) {
            soonest = r;
            soonestDate = next;
          }
        }

        final isDue = !soonestDate.isAfter(DateTime.now());
        final lastMeasured = lastMeasuredAsync.value;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      isDue ? 'Time to update your measurements' : 'Upcoming measurement reminder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lastMeasured == null
                      ? 'You haven\'t recorded any measurements yet.'
                      : 'Last updated ${AppDateUtils.relativeToNow(lastMeasured)}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!isDue) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Next reminder ${AppDateUtils.shortDate.format(soonestDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.push('/session'),
                    child: const Text('Update now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
