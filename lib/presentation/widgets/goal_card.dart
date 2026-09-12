import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/measurement_units.dart';
import '../../core/utils/unit_converter.dart';
import '../../domain/entities/measurement_type.dart';
import '../providers/goal_providers.dart';
import '../providers/repository_providers.dart';

/// User-defined target for a metric (§26) — never a medical
/// recommendation, just a number the user picked for themselves.
class GoalCard extends ConsumerWidget {
  const GoalCard({super.key, required this.type, required this.currentValueCanonical, required this.unitSystem});

  final MeasurementType type;
  final double currentValueCanonical;
  final UnitSystem unitSystem;

  Future<void> _editGoal(BuildContext context, WidgetRef ref, double? existingCanonical) async {
    final controller = TextEditingController(
      text: existingCanonical == null
          ? ''
          : UnitConverter.toDisplay(existingCanonical, type.canonicalUnit, unitSystem).toStringAsFixed(1),
    );
    final unit = UnitConverter.displayUnitFor(type.canonicalUnit, unitSystem);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${type.displayName} goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Target', suffixText: unit.abbreviation),
        ),
        actions: [
          if (existingCanonical != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text('Remove goal', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result == null) return;
    if (result == 'delete') {
      await ref.read(goalRepositoryProvider).delete(type.id);
      return;
    }
    final parsed = double.tryParse(result.trim());
    if (parsed == null) return;
    await ref.read(goalRepositoryProvider).upsert(
          measurementTypeId: type.id,
          targetValueCanonical: UnitConverter.toCanonical(parsed, type.canonicalUnit, unitSystem),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalForTypeProvider(type.id));

    return Card(
      child: ListTile(
        leading: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(goal == null ? 'No goal set' : 'Goal: ${UnitConverter.format(goal.targetValueCanonical, type.canonicalUnit, unitSystem)}'),
        subtitle: goal == null
            ? null
            : Text(
                '${UnitConverter.toDisplay((goal.targetValueCanonical - currentValueCanonical).abs(), type.canonicalUnit, unitSystem).toStringAsFixed(1)} '
                '${UnitConverter.displayUnitFor(type.canonicalUnit, unitSystem).abbreviation} from your target',
              ),
        trailing: TextButton(
          onPressed: () => _editGoal(context, ref, goal?.targetValueCanonical),
          child: Text(goal == null ? 'Set goal' : 'Edit'),
        ),
      ),
    );
  }
}
