import 'package:flutter_test/flutter_test.dart';
import 'package:measure_me/core/utils/shoe_size_converter.dart';
import 'package:measure_me/domain/entities/shoe_item.dart';

void main() {
  group('ShoeSizeConverter', () {
    test('same-system conversion returns the parsed value unchanged', () {
      final result = ShoeSizeConverter.convert('10', ShoeSizeSystem.usMens, ShoeSizeSystem.usMens);
      expect(result, 10);
    });

    test('converts US Men\'s to EU approximately', () {
      final result = ShoeSizeConverter.convert('10', ShoeSizeSystem.usMens, ShoeSizeSystem.eu);
      expect(result, closeTo(43, 0.5));
    });

    test('converts US Men\'s to UK approximately', () {
      final result = ShoeSizeConverter.convert('10', ShoeSizeSystem.usMens, ShoeSizeSystem.uk);
      expect(result, closeTo(9.5, 0.01));
    });

    test('converts US Men\'s to US Women\'s approximately', () {
      final result = ShoeSizeConverter.convert('10', ShoeSizeSystem.usMens, ShoeSizeSystem.usWomens);
      expect(result, closeTo(11.5, 0.01));
    });

    test('round-trips through a third system without drifting', () {
      final toEu = ShoeSizeConverter.convert('9', ShoeSizeSystem.usMens, ShoeSizeSystem.eu)!;
      final backToUsMens = ShoeSizeConverter.convert(toEu.toString(), ShoeSizeSystem.eu, ShoeSizeSystem.usMens);
      expect(backToUsMens, closeTo(9, 1e-9));
    });

    test('returns null for unparsable input', () {
      final result = ShoeSizeConverter.convert('not a size', ShoeSizeSystem.usMens, ShoeSizeSystem.eu);
      expect(result, isNull);
    });
  });
}
