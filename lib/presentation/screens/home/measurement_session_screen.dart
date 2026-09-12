import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../controllers/measurement_session_controller.dart';
import '../../providers/profile_providers.dart';

/// Fast multi-field entry (§24): every tracked measurement type on one
/// screen, save only the fields the user actually filled in.
class MeasurementSessionScreen extends ConsumerStatefulWidget {
  const MeasurementSessionScreen({super.key});

  @override
  ConsumerState<MeasurementSessionScreen> createState() => _MeasurementSessionScreenState();
}

class _MeasurementSessionScreenState extends ConsumerState<MeasurementSessionScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  TextEditingController _controllerFor(String typeId) {
    return _controllers.putIfAbsent(typeId, () => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
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

  Future<void> _save(List<MeasurementType> types, UnitSystem unitSystem) async {
    final values = <String, double>{};
    for (final type in types) {
      final text = _controllers[type.id]?.text.trim();
      if (text == null || text.isEmpty) continue;
      final parsed = double.tryParse(text);
      if (parsed == null) continue;
      values[type.id] = UnitConverter.toCanonical(parsed, type.canonicalUnit, unitSystem);
    }

    if (values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one measurement to save.')),
      );
      return;
    }

    setState(() => _saving = true);
    final failures = await ref.read(measurementSessionControllerProvider).saveSession(
          valuesByTypeIdCanonical: values,
          timestamp: _date,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);

    if (failures.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved. Some values could not sync to health: ${failures.values.first}')),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(sessionFieldTypesProvider);
    final unitSystem = ref.watch(unitSystemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Measurement session')),
      body: typesAsync.when(
        data: (types) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(_date.toLocal().toString().split(' ').first),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 8),
            for (final type in types) ...[
              _MeasurementField(
                type: type,
                controller: _controllerFor(type.id),
                unitSystem: unitSystem,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(types, unitSystem),
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save measurements'),
            ),
            const SizedBox(height: 24),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load measurement types: $e')),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({required this.type, required this.controller, required this.unitSystem});

  final MeasurementType type;
  final TextEditingController controller;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final unit = UnitConverter.displayUnitFor(type.canonicalUnit, unitSystem);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: type.displayName,
        suffixText: unit.abbreviation,
      ),
    );
  }
}
