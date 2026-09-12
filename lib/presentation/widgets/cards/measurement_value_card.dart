import 'package:flutter/material.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_entry.dart';
import '../../../domain/entities/measurement_type.dart';

/// A dashboard card for one measurement type: shows the latest value, or
/// an "Add measurement" empty state when nothing has been recorded yet
/// (§4 — never fabricate a value).
class MeasurementValueCard extends StatelessWidget {
  const MeasurementValueCard({
    super.key,
    required this.type,
    required this.latest,
    required this.unitSystem,
    required this.onTap,
  });

  final MeasurementType type;
  final MeasurementEntry? latest;
  final UnitSystem unitSystem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.displayName,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (latest == null)
                Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Add measurement',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                )
              else ...[
                Text(
                  UnitConverter.format(latest!.valueCanonical, latest!.unit, unitSystem),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateUtils.relativeToNow(latest!.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
