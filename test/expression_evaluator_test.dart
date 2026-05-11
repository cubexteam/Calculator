import 'package:calculator/core/expression_evaluator.dart';
import 'package:calculator/core/expression_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryEvaluate percent modes', () {
    test('100+20% numerical → 100.2', () {
      final v = tryEvaluate('100+20%', PercentMode.numericalValue);
      expect(v, closeTo(100.2, 1e-9));
    });

    test('100+20% proportion → 120', () {
      final v = tryEvaluate('100+20%', PercentMode.proportion);
      expect(v, closeTo(120, 1e-9));
    });

    test('100-20% proportion → 80', () {
      final v = tryEvaluate('100-20%', PercentMode.proportion);
      expect(v, closeTo(80, 1e-9));
    });

    test('100-20% numerical → 99.8', () {
      final v = tryEvaluate('100-20%', PercentMode.numericalValue);
      expect(v, closeTo(99.8, 1e-9));
    });

    test('10*20% → 2', () {
      final v = tryEvaluate('10*20%', PercentMode.numericalValue);
      expect(v, closeTo(2, 1e-9));
    });

    test('100/20% → 500 (режим % для */ не меняется)', () {
      final v = tryEvaluate('100/20%', PercentMode.numericalValue);
      expect(v, closeTo(500, 1e-9));
    });
  });

  group('basic arithmetic', () {
    test('5/5', () {
      expect(tryEvaluate('5/5', PercentMode.numericalValue), 1);
    });

    test('2^3^2 right-associative → 512', () {
      expect(tryEvaluate('2^3^2', PercentMode.numericalValue), closeTo(512, 1e-9));
    });

    test('comma decimal', () {
      expect(tryEvaluate('1,5+1,5', PercentMode.numericalValue), 3);
    });

    test('× and ÷ normalize', () {
      expect(tryEvaluate('6÷2×2', PercentMode.numericalValue), 6);
    });
  });

  group('scientific', () {
    test('sin 90 deg', () {
      expect(tryEvaluate('sin(90)', PercentMode.numericalValue, angleInDegrees: true), closeTo(1, 1e-9));
    });

    test('sqrt', () {
      expect(tryEvaluate('sqrt(16)', PercentMode.numericalValue), 4);
    });

    test('ln e', () {
      expect(tryEvaluate('ln(e)', PercentMode.numericalValue), closeTo(1, 1e-9));
    });
  });

  group('invalid', () {
    test('incomplete returns null', () {
      expect(tryEvaluate('5+', PercentMode.numericalValue), isNull);
    });

    test('empty returns null', () {
      expect(tryEvaluate('', PercentMode.numericalValue), isNull);
    });
  });
}
