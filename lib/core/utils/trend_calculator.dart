/// Direction of change between two values. Deliberately neutral — the app
/// never labels a direction as "good" or "bad" (§8): whether "up" is
/// desirable depends on the metric and the user's own goal.
enum TrendDirection { up, down, stable }

/// Summary statistics for a metric over a set of historical values,
/// oldest-first is NOT required — pass values in chronological order.
class TrendResult {
  final double startingValue;
  final double currentValue;
  final DateTime startingDate;
  final DateTime currentDate;

  const TrendResult({
    required this.startingValue,
    required this.currentValue,
    required this.startingDate,
    required this.currentDate,
  });

  double get absoluteChange => currentValue - startingValue;

  /// Null when [startingValue] is zero (percentage change is undefined).
  double? get percentageChange =>
      startingValue == 0 ? null : (absoluteChange / startingValue) * 100;

  TrendDirection get direction {
    // A small dead-zone avoids flagging floating point noise as a trend.
    const epsilon = 0.05;
    if (absoluteChange.abs() < epsilon) return TrendDirection.stable;
    return absoluteChange > 0 ? TrendDirection.up : TrendDirection.down;
  }
}

class TrendCalculator {
  TrendCalculator._();

  /// Builds a [TrendResult] from a chronologically-ordered list of
  /// (date, value) pairs. Returns null if fewer than 2 points are given.
  static TrendResult? fromSeries(List<({DateTime date, double value})> series) {
    if (series.length < 2) return null;
    final first = series.first;
    final last = series.last;
    return TrendResult(
      startingValue: first.value,
      currentValue: last.value,
      startingDate: first.date,
      currentDate: last.date,
    );
  }

  /// Given a series in newest-first order, finds the point closest to
  /// (but not after) `latest.date - period` and returns a [TrendResult]
  /// comparing it to the newest point. Falls back to the oldest available
  /// point if nothing is that old yet. Used for dashboard copy like
  /// "-2.5 cm since last month".
  static TrendResult? overPeriod(
    List<({DateTime date, double value})> seriesNewestFirst,
    Duration period,
  ) {
    if (seriesNewestFirst.length < 2) return null;
    final latest = seriesNewestFirst.first;
    final cutoff = latest.date.subtract(period);

    var comparison = seriesNewestFirst.last;
    for (final point in seriesNewestFirst.skip(1)) {
      if (!point.date.isAfter(cutoff)) {
        comparison = point;
        break;
      }
      comparison = point;
    }

    return TrendResult(
      startingValue: comparison.value,
      currentValue: latest.value,
      startingDate: comparison.date,
      currentDate: latest.date,
    );
  }
}
