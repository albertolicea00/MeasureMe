import '../constants/measurement_units.dart';

/// Converts between the canonical units values are stored in and the
/// units a user prefers to see/enter (§20). Stored values never change
/// when the user's preferred unit system changes — only the presentation
/// does.
class UnitConverter {
  UnitConverter._();

  static const double _cmPerInch = 2.54;
  static const double _kgPerPound = 0.45359237;

  static double centimetersToInches(double cm) => cm / _cmPerInch;
  static double inchesToCentimeters(double inches) => inches * _cmPerInch;

  static double kilogramsToPounds(double kg) => kg / _kgPerPound;
  static double poundsToKilograms(double lb) => lb * _kgPerPound;

  /// Convert a canonical value to the [DisplayUnit] appropriate for
  /// [system] and [unit]. Percent values are unit-system independent.
  static double toDisplay(double canonicalValue, CanonicalUnit unit, UnitSystem system) {
    switch (unit) {
      case CanonicalUnit.centimeters:
        return system == UnitSystem.metric
            ? canonicalValue
            : centimetersToInches(canonicalValue);
      case CanonicalUnit.kilograms:
        return system == UnitSystem.metric
            ? canonicalValue
            : kilogramsToPounds(canonicalValue);
      case CanonicalUnit.percent:
        return canonicalValue;
    }
  }

  /// Convert a value the user typed (in their preferred display unit) back
  /// to the canonical unit for storage.
  static double toCanonical(double displayValue, CanonicalUnit unit, UnitSystem system) {
    switch (unit) {
      case CanonicalUnit.centimeters:
        return system == UnitSystem.metric
            ? displayValue
            : inchesToCentimeters(displayValue);
      case CanonicalUnit.kilograms:
        return system == UnitSystem.metric
            ? displayValue
            : poundsToKilograms(displayValue);
      case CanonicalUnit.percent:
        return displayValue;
    }
  }

  static DisplayUnit displayUnitFor(CanonicalUnit unit, UnitSystem system) {
    switch (unit) {
      case CanonicalUnit.centimeters:
        return system == UnitSystem.metric ? DisplayUnit.centimeters : DisplayUnit.inches;
      case CanonicalUnit.kilograms:
        return system == UnitSystem.metric ? DisplayUnit.kilograms : DisplayUnit.pounds;
      case CanonicalUnit.percent:
        return DisplayUnit.percent;
    }
  }

  /// Formats a canonical value for display, e.g. "102.5 cm".
  static String format(double canonicalValue, CanonicalUnit unit, UnitSystem system, {int decimals = 1}) {
    final displayValue = toDisplay(canonicalValue, unit, system);
    final displayUnit = displayUnitFor(unit, system);
    return '${_trim(displayValue, decimals)} ${displayUnit.abbreviation}';
  }

  static String _trim(double value, int decimals) {
    final fixed = value.toStringAsFixed(decimals);
    if (!fixed.contains('.')) return fixed;
    var trimmed = fixed;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
