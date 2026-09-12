import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/core/constants/measurement_units.dart';
import 'package:measure_me/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter length', () {
    test('metric round-trips unchanged', () {
      expect(
        UnitConverter.toDisplay(100, CanonicalUnit.centimeters, UnitSystem.metric),
        closeTo(100, 1e-9),
      );
    });

    test('converts centimeters to inches for imperial display', () {
      final inches = UnitConverter.toDisplay(100, CanonicalUnit.centimeters, UnitSystem.imperial);
      expect(inches, closeTo(39.37, 0.01));
    });

    test('toCanonical inverts toDisplay for imperial length', () {
      const original = 102.5;
      final displayed = UnitConverter.toDisplay(original, CanonicalUnit.centimeters, UnitSystem.imperial);
      final backToCanonical =
          UnitConverter.toCanonical(displayed, CanonicalUnit.centimeters, UnitSystem.imperial);
      expect(backToCanonical, closeTo(original, 1e-9));
    });
  });

  group('UnitConverter mass', () {
    test('converts kilograms to pounds', () {
      final lb = UnitConverter.toDisplay(82.4, CanonicalUnit.kilograms, UnitSystem.imperial);
      expect(lb, closeTo(181.66, 0.1));
    });

    test('metric mass is unchanged', () {
      expect(
        UnitConverter.toDisplay(82.4, CanonicalUnit.kilograms, UnitSystem.metric),
        closeTo(82.4, 1e-9),
      );
    });
  });

  group('UnitConverter percent', () {
    test('percent is unit-system independent', () {
      expect(UnitConverter.toDisplay(18, CanonicalUnit.percent, UnitSystem.metric), 18);
      expect(UnitConverter.toDisplay(18, CanonicalUnit.percent, UnitSystem.imperial), 18);
    });
  });

  group('UnitConverter.format', () {
    test('formats with the correct abbreviation per system', () {
      expect(UnitConverter.format(100, CanonicalUnit.centimeters, UnitSystem.metric), '100 cm');
      expect(
        UnitConverter.format(100, CanonicalUnit.centimeters, UnitSystem.imperial, decimals: 2),
        '39.37 in',
      );
    });

    test('trims trailing zeros', () {
      expect(UnitConverter.format(80, CanonicalUnit.kilograms, UnitSystem.metric), '80 kg');
    });
  });

  test('changing unit system never changes the stored canonical value', () {
    // Storing must always happen in canonical units — this test documents
    // that invariant by confirming a display-unit change round-trips.
    const canonical = 100.0;
    final displayedImperial = UnitConverter.toDisplay(canonical, CanonicalUnit.centimeters, UnitSystem.imperial);
    final backToCanonical =
        UnitConverter.toCanonical(displayedImperial, CanonicalUnit.centimeters, UnitSystem.imperial);
    expect(backToCanonical, closeTo(canonical, 1e-9));
  });
}
