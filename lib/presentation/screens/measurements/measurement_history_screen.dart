import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/trend_calculator.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_entry.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/charts/chart_range_selector.dart';
import '../../widgets/charts/measurement_line_chart.dart';
import '../../widgets/empty_states/empty_state.dart';
import '../../widgets/forms/measurement_entry_form_sheet.dart';
import '../../widgets/trend_indicator.dart';

class MeasurementHistoryScreen extends ConsumerStatefulWidget {
  const MeasurementHistoryScreen({super.key, required this.typeId});

  final String typeId;

  @override
  ConsumerState<MeasurementHistoryScreen> createState() => _MeasurementHistoryScreenState();
}

class _MeasurementHistoryScreenState extends ConsumerState<MeasurementHistoryScreen> {
  ChartRange _range = ChartRange.threeMonths;

  Future<void> _confirmDelete(MeasurementEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this measurement?'),
        content: Text(
          'This removes the entry from ${AppDateUtils.mediumDate.format(entry.timestamp)}. This can\'t be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(measurementRepositoryProvider).deleteEntry(entry.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(measurementTypesProvider);
    final historyAsync = ref.watch(measurementHistoryProvider(widget.typeId));
    final unitSystem = ref.watch(unitSystemProvider);

    final type = typesAsync.value?.firstWhere(
      (t) => t.id == widget.typeId,
      orElse: () => MeasurementTypeCatalog.byId(widget.typeId) ??
          const MeasurementType(
            id: 'unknown',
            displayName: 'Measurement',
            category: MeasurementCategory.custom,
            canonicalUnit: CanonicalUnit.centimeters,
          ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(type?.displayName.toUpperCase() ?? '')),
      body: historyAsync.when(
        data: (history) {
          if (type == null) return const SizedBox.shrink();
          if (history.isEmpty) {
            return EmptyState(
              icon: Icons.show_chart,
              message: 'Add a few measurements to start seeing your progress.',
              actionLabel: 'Add measurement',
              onAction: () => MeasurementEntryFormSheet.show(context, type: type, unitSystem: unitSystem),
            );
          }

          final current = history.first;
          final previous = history.length > 1 ? history[1] : null;
          final cutoff = _range.startDate(current.timestamp);
          final filtered = cutoff == null
              ? history
              : history.where((e) => !e.timestamp.isBefore(cutoff)).toList();
          final chartPoints = filtered
              .map((e) => (date: e.timestamp, value: e.valueCanonical))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (type.instructions != null) ...[
                Text(type.instructions!, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _StatBlock(
                      label: 'Current',
                      value: UnitConverter.format(current.valueCanonical, current.unit, unitSystem),
                    ),
                  ),
                  if (previous != null)
                    Expanded(
                      child: _StatBlock(
                        label: 'Previous',
                        value: UnitConverter.format(previous.valueCanonical, previous.unit, unitSystem),
                      ),
                    ),
                  if (previous != null)
                    Expanded(
                      child: _ChangeBlock(current: current, previous: previous, unitSystem: unitSystem),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (chartPoints.length >= 2) ...[
                ChartRangeSelector(selected: _range, onChanged: (r) => setState(() => _range = r)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: MeasurementLineChart(
                    points: chartPoints,
                    unit: type.canonicalUnit,
                    unitSystem: unitSystem,
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Add one more measurement to see a chart.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Text('History', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final entry in history)
                Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  confirmDismiss: (_) async {
                    await _confirmDelete(entry);
                    return false;
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(UnitConverter.format(entry.valueCanonical, entry.unit, unitSystem)),
                    subtitle: Text(
                      entry.notes == null
                          ? AppDateUtils.shortDate.format(entry.timestamp)
                          : '${AppDateUtils.shortDate.format(entry.timestamp)} · ${entry.notes}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => MeasurementEntryFormSheet.show(
                      context,
                      type: type,
                      unitSystem: unitSystem,
                      existing: entry,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load history: $e')),
      ),
      floatingActionButton: type == null
          ? null
          : FloatingActionButton(
              heroTag: 'measurementHistoryFab-${widget.typeId}',
              onPressed: () => MeasurementEntryFormSheet.show(context, type: type, unitSystem: unitSystem),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _ChangeBlock extends StatelessWidget {
  const _ChangeBlock({required this.current, required this.previous, required this.unitSystem});

  final MeasurementEntry current;
  final MeasurementEntry previous;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final trend = TrendCalculator.fromSeries([
      (date: previous.timestamp, value: previous.valueCanonical),
      (date: current.timestamp, value: current.valueCanonical),
    ])!;
    final displayChange = UnitConverter.toDisplay(trend.absoluteChange.abs(), current.unit, unitSystem);
    final sign = trend.absoluteChange > 0 ? '+' : (trend.absoluteChange < 0 ? '-' : '');
    final unitAbbr = UnitConverter.displayUnitFor(current.unit, unitSystem).abbreviation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Change', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            TrendIndicator(trend.direction),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$sign${displayChange.toStringAsFixed(1)} $unitAbbr',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
