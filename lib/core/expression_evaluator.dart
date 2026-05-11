import 'dart:math' as math;

import 'expression_ast.dart';
import 'expression_parser.dart';

double evalExpr(
  Expr e,
  PercentMode mode, {
  required bool angleInDegrees,
}) {
  if (e is NumberExpr) return e.value;
  if (e is UnaryMinus) {
    return -evalExpr(e.inner, mode, angleInDegrees: angleInDegrees);
  }
  if (e is PercentExpr) {
    return _percentValue(e, mode, angleInDegrees: angleInDegrees);
  }
  if (e is FuncExpr) {
    final v = evalExpr(e.arg, mode, angleInDegrees: angleInDegrees);
    return _evalFunc(e.name, v, angleInDegrees);
  }
  if (e is BinaryExpr) {
    return _evalBinary(e, mode, angleInDegrees: angleInDegrees);
  }
  throw StateError('Unknown expr');
}

double _percentValue(
  PercentExpr p,
  PercentMode mode, {
  required bool angleInDegrees,
}) {
  return evalExpr(p.inner, mode, angleInDegrees: angleInDegrees) / 100;
}

double _evalBinary(
  BinaryExpr e,
  PercentMode mode, {
  required bool angleInDegrees,
}) {
  final left = evalExpr(e.left, mode, angleInDegrees: angleInDegrees);

  if (e.op == '+' && e.right is PercentExpr) {
    final pr = e.right as PercentExpr;
    final p = evalExpr(pr.inner, mode, angleInDegrees: angleInDegrees);
    if (mode == PercentMode.proportion) {
      return left + left * p / 100;
    }
    return left + p / 100;
  }
  if (e.op == '-' && e.right is PercentExpr) {
    final pr = e.right as PercentExpr;
    final p = evalExpr(pr.inner, mode, angleInDegrees: angleInDegrees);
    if (mode == PercentMode.proportion) {
      return left - left * p / 100;
    }
    return left - p / 100;
  }
  if (e.op == '*' && e.right is PercentExpr) {
    final pr = e.right as PercentExpr;
    final frac = evalExpr(pr.inner, mode, angleInDegrees: angleInDegrees) / 100;
    return left * frac;
  }
  if (e.op == '/' && e.right is PercentExpr) {
    final pr = e.right as PercentExpr;
    final frac = evalExpr(pr.inner, mode, angleInDegrees: angleInDegrees) / 100;
    if (frac == 0) {
      throw const FormatException('Деление на ноль');
    }
    return left / frac;
  }

  final right = evalExpr(e.right, mode, angleInDegrees: angleInDegrees);
  switch (e.op) {
    case '+':
      return left + right;
    case '-':
      return left - right;
    case '*':
      return left * right;
    case '/':
      if (right == 0) {
        throw const FormatException('Деление на ноль');
      }
      return left / right;
    case '^':
      return math.pow(left, right).toDouble();
    default:
      throw FormatException('Неизвестный оператор ${e.op}');
  }
}

double _evalFunc(String name, double v, bool angleInDegrees) {
  double rad(double x) => angleInDegrees ? x * math.pi / 180 : x;
  double invRad(double x) => angleInDegrees ? x * 180 / math.pi : x;

  switch (name) {
    case 'sin':
      return math.sin(rad(v));
    case 'cos':
      return math.cos(rad(v));
    case 'tan':
      return math.tan(rad(v));
    case 'asin':
      return invRad(math.asin(v));
    case 'acos':
      return invRad(math.acos(v));
    case 'atan':
      return invRad(math.atan(v));
    case 'sqrt':
      if (v < 0) throw const FormatException('√ из отрицательного');
      return math.sqrt(v);
    case 'ln':
      if (v <= 0) throw const FormatException('ln из неположительного');
      return math.log(v);
    case 'log':
      if (v <= 0) throw const FormatException('log из неположительного');
      return math.log(v) / math.ln10;
    default:
      throw FormatException('Функция $name');
  }
}

String normalizeForParse(String raw) {
  return raw
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('−', '-')
      .replaceAll(',', '.')
      .replaceAll(' ', '');
}

double? tryEvaluate(String raw, PercentMode mode, {bool angleInDegrees = false}) {
  final s = normalizeForParse(raw);
  if (s.isEmpty) return null;
  try {
    final ast = ExpressionParser(s).parse();
    return evalExpr(ast, mode, angleInDegrees: angleInDegrees);
  } on Object {
    return null;
  }
}