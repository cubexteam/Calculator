import 'package:calculator/core/display_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trailingOperator', () {
    expect(DisplayMath.trailingOperator('3+'), '+');
    expect(DisplayMath.trailingOperator('3×'), '×');
    expect(DisplayMath.trailingOperator('3'), isNull);
  });
}
