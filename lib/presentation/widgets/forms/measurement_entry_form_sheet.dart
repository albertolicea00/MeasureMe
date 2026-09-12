import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_entry.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../providers/repository_providers.dart';

/// Reusable measurement entry form (§6): name, value + unit, date, and
/// optional notes. Works for both adding a new value and editing a
/// previously recorded one — editing never overwrites history in place,
/// it updates that specific historical row only.
class MeasurementEntryFormSheet extends ConsumerStatefulWidget {
  const MeasurementEntryFormSheet({
    super.key,
    required this.type,
    required this.unitSystem,
    this.existing,
  });

  final MeasurementType type;
  final UnitSystem unitSystem;
  final MeasurementEntry? existing;

  static Future<void> show(
    BuildContext context, {
    required MeasurementType type,
    required UnitSystem unitSystem,
    MeasurementEntry? existing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MeasurementEntryFormSheet(type: type, unitSystem: unitSystem, existing: existing),
    );
  }

  @override
  ConsumerState<MeasurementEntryFormSheet> createState() => _MeasurementEntryFormSheetState();
}

class _MeasurementEntryFormSheetState extends ConsumerState<MeasurementEntryFormSheet> {
  late final TextEditingController _valueController;
  late final TextEditingController _notesController;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final displayValue = existing == null
        ? null
        : UnitConverter.toDisplay(existing.valueCanonical, existing.unit, widget.unitSystem);
    _valueController = TextEditingController(text: displayValue?.toString() ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _date = existing?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final parsed = double.tryParse(_valueController.text.trim());
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number.')),
      );
      return;
    }
    setState(() => _saving = true);
    final canonical = UnitConverter.toCanonical(parsed, widget.type.canonicalUnit, widget.unitSystem);
    final repo = ref.read(measurementRepositoryProvider);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (widget.existing == null) {
      await repo.addEntry(
        typeId: widget.type.id,
        valueCanonical: canonical,
        timestamp: _date,
        notes: notes,
      );
    } else {
      await repo.updateEntry(widget.existing!.copyWith(
        valueCanonical: canonical,
        timestamp: _date,
        notes: notes,
      ));
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final unit = UnitConverter.displayUnitFor(widget.type.canonicalUnit, widget.unitSystem);
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
          Text(widget.type.displayName, style: Theme.of(context).textTheme.titleLarge),
          if (widget.type.instructions != null) ...[
            const SizedBox(height: 4),
            Text(widget.type.instructions!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            autofocus: widget.existing == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Value', suffixText: unit.abbreviation),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(AppDateUtils.mediumDate.format(_date)),
            trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.existing == null ? 'Save measurement' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}
