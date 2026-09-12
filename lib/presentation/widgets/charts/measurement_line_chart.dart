import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/unit_converter.dart';

/// A single (date, canonical value) point to plot.
typedef ChartPoint = ({DateTime date, double value});

/// Simple line chart for measurement/progress history. Values passed in
/// are canonical; display conversion happens here so callers never juggle
/// units themselves.
class MeasurementLineChart extends StatelessWidget {
  const MeasurementLineChart({
    super.key,
    required this.points,
    required this.unit,
    required this.unitSystem,
  });

  final List<ChartPoint> points;
  final CanonicalUnit unit;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final displayValues = sorted
        .map((p) => UnitConverter.toDisplay(p.value, unit, unitSystem))
        .toList();

    final minY = displayValues.reduce((a, b) => a < b ? a : b);
    final maxY = displayValues.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    final spots = List.generate(
      sorted.length,
      (i) => FlSpot(i.toDouble(), displayValues[i]),
    );

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY + padding * 2) / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (sorted.length / 4).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(AppDateUtils.monthDay.format(sorted[i].date), style: theme.textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final point = sorted[spot.x.toInt()];
              return LineTooltipItem(
                '${UnitConverter.format(point.value, unit, unitSystem)}\n${AppDateUtils.shortDate.format(point.date)}',
                theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onInverseSurface),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: theme.colorScheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(show: sorted.length <= 30),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
