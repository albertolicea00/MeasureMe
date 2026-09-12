import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/measurement_units.dart';
import '../../../../core/utils/trend_calculator.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../domain/entities/measurement_type.dart';
import '../../../providers/measurement_providers.dart';
import '../../../providers/profile_providers.dart';
import '../../../widgets/trend_indicator.dart';

/// Dashboard summary of recent change across the metrics most people
/// check first (§4). Each row only appears once that metric has at least
/// two recorded points — no fabricated "0.0" placeholders.
class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const types = [
      MeasurementTypeCatalog.weight,
      MeasurementTypeCatalog.waist,
      MeasurementTypeCatalog.chest,
    ];

    final rows = types
        .map((t) => _SummaryRowData(type: t))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final row in rows) _SummaryRow(type: row.type),
          ],
        ),
      ),
    );
  }
}

class _SummaryRowData {
  const _SummaryRowData({required this.type});
  final MeasurementType type;
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.type});

  final MeasurementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(measurementHistoryProvider(type.id));
    final unitSystem = ref.watch(unitSystemProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      data: (history) {
        if (history.length < 2) return const SizedBox.shrink();
        final series = history.map((e) => (date: e.timestamp, value: e.valueCanonical)).toList();
        final trend = TrendCalculator.overPeriod(series, const Duration(days: 30));
        if (trend == null) return const SizedBox.shrink();

        final changeDisplay = UnitConverter.toDisplay(trend.absoluteChange.abs(), type.canonicalUnit, unitSystem);
        final sign = trend.absoluteChange > 0 ? '+' : (trend.absoluteChange < 0 ? '-' : '');
        final unitAbbr = UnitConverter.displayUnitFor(type.canonicalUnit, unitSystem).abbreviation;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 70, child: Text(type.displayName, style: theme.textTheme.bodyMedium)),
              TrendIndicator(trend.direction),
              const SizedBox(width: 6),
              Text(
                '$sign${changeDisplay.toStringAsFixed(1)} $unitAbbr since last month',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
