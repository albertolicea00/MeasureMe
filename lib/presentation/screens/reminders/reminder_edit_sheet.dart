import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/reminder.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repository_providers.dart';

/// Add or edit a reminder (§14). Requests notification permission the
/// first time the user creates one — never at app launch (§33).
class ReminderEditSheet extends ConsumerStatefulWidget {
  const ReminderEditSheet({super.key, this.existing});

  final Reminder? existing;

  static Future<void> show(BuildContext context, {Reminder? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReminderEditSheet(existing: existing),
    );
  }

  @override
  ConsumerState<ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends ConsumerState<ReminderEditSheet> {
  late ReminderFrequency _frequency = widget.existing?.frequency ?? ReminderFrequency.monthly;
  late String? _measurementTypeId = widget.existing?.measurementTypeId;
  late TimeOfDay _time = widget.existing == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay(hour: widget.existing!.hour, minute: widget.existing!.minute);
  late final _customDaysController =
      TextEditingController(text: widget.existing?.customIntervalDays?.toString() ?? '30');
  bool _saving = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final isNew = widget.existing == null;
    final customDays = int.tryParse(_customDaysController.text.trim());

    final reminderRepo = ref.read(reminderRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);

    if (isNew) {
      final hasPermission = await notificationService.hasPermission();
      if (!hasPermission) {
        await notificationService.requestPermission();
      }
      await reminderRepo.add(Reminder(
        id: '',
        measurementTypeId: _measurementTypeId,
        frequency: _frequency,
        customIntervalDays: _frequency == ReminderFrequency.custom ? customDays : null,
        hour: _time.hour,
        minute: _time.minute,
        enabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } else {
      await reminderRepo.update(widget.existing!.copyWith(
        measurementTypeId: _measurementTypeId,
        clearMeasurementTypeId: _measurementTypeId == null,
        frequency: _frequency,
        customIntervalDays: _frequency == ReminderFrequency.custom ? customDays : null,
        hour: _time.hour,
        minute: _time.minute,
      ));
    }

    final all = await reminderRepo.getAll();
    await notificationService.reconcileAll(all);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(measurementTypesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'New reminder' : 'Edit reminder', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          typesAsync.when(
            data: (types) => DropdownButtonFormField<String?>(
              initialValue: _measurementTypeId,
              decoration: const InputDecoration(labelText: 'What to remind about'),
              items: [
                const DropdownMenuItem(value: null, child: Text('General measurement update')),
                for (final t in types.where((t) => t.isTracked))
                  DropdownMenuItem(value: t.id, child: Text(t.displayName)),
              ],
              onChanged: (v) => setState(() => _measurementTypeId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ReminderFrequency>(
            initialValue: _frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: [
              for (final f in ReminderFrequency.values) DropdownMenuItem(value: f, child: Text(f.label)),
            ],
            onChanged: (v) => setState(() => _frequency = v ?? _frequency),
          ),
          if (_frequency == ReminderFrequency.custom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Every how many days'),
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(_time.format(context)),
            trailing: TextButton(onPressed: _pickTime, child: const Text('Change')),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save reminder'),
          ),
        ],
      ),
    );
  }
}
