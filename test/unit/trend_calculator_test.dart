import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/core/utils/trend_calculator.dart';

void main() {
  group('TrendCalculator.fromSeries', () {
    test('returns null with fewer than 2 points', () {
      expect(TrendCalculator.fromSeries([]), isNull);
      expect(TrendCalculator.fromSeries([(date: DateTime(2026, 1, 1), value: 80)]), isNull);
    });

    test('computes absolute and percentage change', () {
      final result = TrendCalculator.fromSeries([
        (date: DateTime(2026, 1, 1), value: 86),
        (date: DateTime(2026, 3, 1), value: 82),
      ]);
      expect(result, isNotNull);
      expect(result!.absoluteChange, closeTo(-4, 1e-9));
      expect(result.percentageChange, closeTo(-4.651, 0.01));
    });

    test('direction is down when value decreases', () {
      final result = TrendCalculator.fromSeries([
        (date: DateTime(2026, 1, 1), value: 86),
        (date: DateTime(2026, 3, 1), value: 82),
      ])!;
      expect(result.direction, TrendDirection.down);
    });

    test('direction is up when value increases', () {
      final result = TrendCalculator.fromSeries([
        (date: DateTime(2026, 1, 1), value: 36),
        (date: DateTime(2026, 3, 1), value: 38),
      ])!;
      expect(result.direction, TrendDirection.up);
    });

    test('direction is stable within the epsilon dead-zone', () {
      final result = TrendCalculator.fromSeries([
        (date: DateTime(2026, 1, 1), value: 82.40),
        (date: DateTime(2026, 1, 2), value: 82.41),
      ])!;
      expect(result.direction, TrendDirection.stable);
    });

    test('percentageChange is null when starting value is zero', () {
      final result = TrendCalculator.fromSeries([
        (date: DateTime(2026, 1, 1), value: 0),
        (date: DateTime(2026, 1, 2), value: 5),
      ])!;
      expect(result.percentageChange, isNull);
    });
  });

  group('TrendCalculator.overPeriod', () {
    test('compares the newest point to the closest point at or before the cutoff', () {
      final seriesNewestFirst = [
        (date: DateTime(2026, 3, 1), value: 82.0), // latest
        (date: DateTime(2026, 2, 15), value: 83.5),
        (date: DateTime(2026, 1, 28), value: 85.0), // ~32 days before latest
        (date: DateTime(2026, 1, 1), value: 86.0),
      ];
      final result = TrendCalculator.overPeriod(seriesNewestFirst, const Duration(days: 30));
      expect(result, isNotNull);
      expect(result!.currentValue, 82.0);
      expect(result.startingValue, 85.0);
    });

    test('falls back to the oldest point when nothing is old enough', () {
      final seriesNewestFirst = [
        (date: DateTime(2026, 3, 10), value: 82.0),
        (date: DateTime(2026, 3, 5), value: 82.5),
      ];
      final result = TrendCalculator.overPeriod(seriesNewestFirst, const Duration(days: 30));
      expect(result!.startingValue, 82.5);
    });

    test('returns null with fewer than 2 points', () {
      expect(
        TrendCalculator.overPeriod([(date: DateTime(2026, 1, 1), value: 1)], const Duration(days: 30)),
        isNull,
      );
    });
  });
}
