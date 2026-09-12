import '../../domain/entities/shoe_item.dart';

/// Approximate conversions between shoe sizing systems (§12).
///
/// Shoe sizing is not standardized across brands or even across shoe
/// styles from the same brand, so these formulas are explicitly
/// approximate — a *suggestion*, never a guarantee. The app always lets
/// users record the actual size that fits them per brand
/// ([ShoeItem]) instead of relying on conversion alone.
class ShoeSizeConverter {
  ShoeSizeConverter._();

  /// Converts any parsed size to a US Men's-equivalent pivot value.
  static double _toUsMensPivot(double value, ShoeSizeSystem system) {
    switch (system) {
      case ShoeSizeSystem.usMens:
        return value;
      case ShoeSizeSystem.usWomens:
        return value - 1.5;
      case ShoeSizeSystem.eu:
        return value - 33;
      case ShoeSizeSystem.uk:
        return value + 0.5;
    }
  }

  static double _fromUsMensPivot(double usMens, ShoeSizeSystem system) {
    switch (system) {
      case ShoeSizeSystem.usMens:
        return usMens;
      case ShoeSizeSystem.usWomens:
        return usMens + 1.5;
      case ShoeSizeSystem.eu:
        return usMens + 33;
      case ShoeSizeSystem.uk:
        return usMens - 0.5;
    }
  }

  /// Returns an approximate equivalent size in [targetSystem]. Returns
  /// null if [value] cannot be parsed as a number.
  static double? convert(String value, ShoeSizeSystem fromSystem, ShoeSizeSystem targetSystem) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return null;
    if (fromSystem == targetSystem) return parsed;
    final pivot = _toUsMensPivot(parsed, fromSystem);
    return _fromUsMensPivot(pivot, targetSystem);
  }

  static String formatSize(double size) {
    final rounded = (size * 2).round() / 2;
    if (rounded == rounded.roundToDouble()) return rounded.toStringAsFixed(0);
    return rounded.toStringAsFixed(1);
  }
}
