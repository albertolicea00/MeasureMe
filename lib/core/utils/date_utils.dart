import 'package:intl/intl.dart';

/// Time window presets for measurement history charts (§7).
enum ChartRange { sevenDays, thirtyDays, threeMonths, sixMonths, oneYear, allTime }

extension ChartRangeLabel on ChartRange {
  String get label {
    switch (this) {
      case ChartRange.sevenDays:
        return '7D';
      case ChartRange.thirtyDays:
        return '30D';
      case ChartRange.threeMonths:
        return '3M';
      case ChartRange.sixMonths:
        return '6M';
      case ChartRange.oneYear:
        return '1Y';
      case ChartRange.allTime:
        return 'All';
    }
  }

  /// The earliest timestamp to include, or null for [ChartRange.allTime].
  DateTime? startDate(DateTime from) {
    switch (this) {
      case ChartRange.sevenDays:
        return from.subtract(const Duration(days: 7));
      case ChartRange.thirtyDays:
        return from.subtract(const Duration(days: 30));
      case ChartRange.threeMonths:
        return DateTime(from.year, from.month - 3, from.day);
      case ChartRange.sixMonths:
        return DateTime(from.year, from.month - 6, from.day);
      case ChartRange.oneYear:
        return DateTime(from.year - 1, from.month, from.day);
      case ChartRange.allTime:
        return null;
    }
  }
}

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat mediumDate = DateFormat('MMMM d, y');
  static final DateFormat shortDate = DateFormat('MMM d, y');
  static final DateFormat monthDay = DateFormat('MMM d');

  /// e.g. "12 days ago", "today", "yesterday".
  static String relativeToNow(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) return 'today';
    if (diffDays == 1) return 'yesterday';
    if (diffDays > 1) return '$diffDays days ago';
    if (diffDays == -1) return 'tomorrow';
    return 'in ${-diffDays} days';
  }
}
