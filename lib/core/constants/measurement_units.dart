/// Canonical unit a measurement value is stored in. Values are ALWAYS
/// persisted in these units; imperial/metric display conversion happens
/// only in the presentation layer (see [UnitConverter]).
enum CanonicalUnit {
  centimeters,
  kilograms,
  percent,
}

/// The unit system the user prefers for display and input.
enum UnitSystem {
  metric,
  imperial,
}

/// A concrete display unit shown to the user.
enum DisplayUnit {
  centimeters,
  inches,
  kilograms,
  pounds,
  percent,
}

extension DisplayUnitLabel on DisplayUnit {
  String get abbreviation {
    switch (this) {
      case DisplayUnit.centimeters:
        return 'cm';
      case DisplayUnit.inches:
        return 'in';
      case DisplayUnit.kilograms:
        return 'kg';
      case DisplayUnit.pounds:
        return 'lb';
      case DisplayUnit.percent:
        return '%';
    }
  }
}
