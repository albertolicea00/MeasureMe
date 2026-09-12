import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/trend_calculator.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/charts/chart_range_selector.dart';
import '../../widgets/charts/measurement_line_chart.dart';
import '../../widgets/empty_states/empty_state.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/trend_indicator.dart';

/// Dedicated progress dashboard (§8) — the user picks a metric, sees
/// current/starting/change/percentage/trend and a chart. Trend direction
/// is shown neutrally: an increase is never implied to be good or bad.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? _selectedTypeId;
  ChartRange _range = ChartRange.sixMonths;

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(measurementTypesProvider);
    final unitSystem = ref.watch(unitSystemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: typesAsync.when(
        data: (types) {
          final tracked = types.where((t) => t.isTracked).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          if (tracked.isEmpty) {
            return const EmptyState(
              icon: Icons.show_chart,
              message: 'Add a few measurements to start seeing your progress.',
            );
          }
          final selectedId = _selectedTypeId ?? tracked.first.id;
          final selectedType = tracked.firstWhere((t) => t.id == selectedId, orElse: () => tracked.first);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedType.id,
                  decoration: const InputDecoration(labelText: 'Metric'),
                  items: [
                    for (final type in tracked)
                      DropdownMenuItem(value: type.id, child: Text(type.displayName)),
                  ],
                  onChanged: (value) => setState(() => _selectedTypeId = value),
                ),
              ),
              Expanded(
                child: _ProgressBody(
                  type: selectedType,
                  unitSystem: unitSystem,
                  range: _range,
                  onRangeChanged: (r) => setState(() => _range = r),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({
    required this.type,
    required this.unitSystem,
    required this.range,
    required this.onRangeChanged,
  });

  final MeasurementType type;
  final UnitSystem unitSystem;
  final ChartRange range;
  final ValueChanged<ChartRange> onRangeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(measurementHistoryProvider(type.id));

    return historyAsync.when(
      data: (historyNewestFirst) {
        if (historyNewestFirst.length < 2) {
          return const EmptyState(
            icon: Icons.show_chart,
            message: 'Add a few measurements to start seeing your progress.',
          );
        }
        final oldestFirst = historyNewestFirst.reversed.toList();
        final cutoff = range.startDate(historyNewestFirst.first.timestamp);
        final filtered = cutoff == null
            ? oldestFirst
            : oldestFirst.where((e) => !e.timestamp.isBefore(cutoff)).toList();

        final fullSeries = oldestFirst.map((e) => (date: e.timestamp, value: e.valueCanonical)).toList();
        final trend = TrendCalculator.fromSeries(fullSeries)!;
        final chartPoints = (filtered.length >= 2 ? filtered : oldestFirst)
            .map((e) => (date: e.timestamp, value: e.valueCanonical))
            .toList();

        final currentDisplay = UnitConverter.format(trend.currentValue, type.canonicalUnit, unitSystem);
        final absChangeDisplay =
            UnitConverter.toDisplay(trend.absoluteChange.abs(), type.canonicalUnit, unitSystem);
        final sign = trend.absoluteChange > 0 ? '+' : (trend.absoluteChange < 0 ? '-' : '');
        final unitAbbr = UnitConverter.displayUnitFor(type.canonicalUnit, unitSystem).abbreviation;
        final pct = trend.percentageChange;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(currentDisplay, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                TrendIndicator(trend.direction),
                const SizedBox(width: 6),
                Text(
                  '$sign${absChangeDisplay.toStringAsFixed(1)} $unitAbbr'
                  '${pct != null ? '  (${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%)' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Since ${AppDateUtils.shortDate.format(trend.startingDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ChartRangeSelector(selected: range, onChanged: onRangeChanged),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: MeasurementLineChart(points: chartPoints, unit: type.canonicalUnit, unitSystem: unitSystem),
            ),
            const SizedBox(height: 24),
            _StatsRow(type: type, unitSystem: unitSystem, trend: trend),
            const SizedBox(height: 16),
            GoalCard(type: type, currentValueCanonical: trend.currentValue, unitSystem: unitSystem),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('$e')),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.type, required this.unitSystem, required this.trend});

  final MeasurementType type;
  final UnitSystem unitSystem;
  final TrendResult trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Starting',
                value: UnitConverter.format(trend.startingValue, type.canonicalUnit, unitSystem),
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Current',
                value: UnitConverter.format(trend.currentValue, type.canonicalUnit, unitSystem),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
