import 'package:calculator/core/expression_ast.dart';
import 'package:calculator/core/expression_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpressionParser', () {
    test('parses nested parens', () {
      final e = ExpressionParser('(1+2)*3').parse();
      expect(e, isA<BinaryExpr>());
      final b = e as BinaryExpr;
      expect(b.op, '*');
    });

    test('parses percent suffix', () {
      final e = ExpressionParser('20%').parse();
      expect(e, isA<PercentExpr>());
    });

    test('parses func', () {
      final e = ExpressionParser('sin(0)').parse();
      expect(e, isA<FuncExpr>());
      expect((e as FuncExpr).name, 'sin');
    });

    test('pi constant', () {
      final e = ExpressionParser('pi').parse();
      expect(e, isA<NumberExpr>());
    });

    test('throws on invalid token', () {
      expect(() => ExpressionParser('2&3').parse(), throwsException);
    });
  });
}
