import 'dart:math' as math;

import 'expression_ast.dart';

/// Режим для A+B% и A−B% (как в настройках MIUI).
enum PercentMode {
  /// A + B% = A + (B/100)
  numericalValue,

  /// A + B% = A + A*(B/100)
  proportion,
}

class ExpressionParser {
  ExpressionParser(this.src);

  final String src;
  int pos = 0;

  void skipWs() {
    while (pos < src.length && (src[pos] == ' ' || src[pos] == '\t')) {
      pos++;
    }
  }

  bool match(String ch) {
    skipWs();
    if (pos < src.length && src[pos] == ch) {
      pos++;
      return true;
    }
    return false;
  }

  Expr parse() {
    skipWs();
    if (pos >= src.length) {
      throw const FormatException('Пустое выражение');
    }
    final e = parseAddSub();
    skipWs();
    if (pos < src.length) {
      throw FormatException('Лишние символы: …${src.substring(pos)}');
    }
    return e;
  }

  Expr parseAddSub() {
    var left = parseMulDiv();
    while (true) {
      skipWs();
      if (pos >= src.length) break;
      final op = src[pos];
      if (op != '+' && op != '-') break;
      pos++;
      final right = parseMulDiv();
      left = BinaryExpr(op, left, right);
    }
    return left;
  }

  Expr parseMulDiv() {
    var left = parsePow();
    while (true) {
      skipWs();
      if (pos >= src.length) break;
      final op = src[pos];
      if (op != '*' && op != '/') break;
      pos++;
      final right = parsePow();
      left = BinaryExpr(op, left, right);
    }
    return left;
  }

  Expr parsePow() {
    var left = parseUnary();
    skipWs();
    if (pos < src.length && src[pos] == '^') {
      pos++;
      final right = parsePow();
      left = BinaryExpr('^', left, right);
    }
    return left;
  }

  Expr parseUnary() {
    skipWs();
    if (match('-')) {
      return UnaryMinus(parseUnary());
    }
    if (match('+')) {
      return parseUnary();
    }
    return parsePostfix();
  }

  Expr parsePostfix() {
    final p = parsePrimary();
    skipWs();
    if (match('%')) {
      return PercentExpr(p);
    }
    return p;
  }

  Expr parsePrimary() {
    skipWs();
    if (pos >= src.length) {
      throw const FormatException('Неожиданный конец');
    }
    final c = src[pos];
    if (c == '(') {
      pos++;
      final inner = parseAddSub();
      if (!match(')')) {
        throw const FormatException('Ожидалась «)»');
      }
      return inner;
    }
    if (_isDigit(c) || c == '.' || c == ',') {
      return NumberExpr(_readNumber());
    }
    if (_isLetter(c)) {
      final id = _readIdent().toLowerCase();
      if (id == 'pi') {
        return NumberExpr(math.pi);
      }
      if (id == 'e') {
        return NumberExpr(math.e);
      }
      if (!_isFunc(id)) {
        throw FormatException('Неизвестная функция: $id');
      }
      if (!match('(')) {
        throw FormatException('Ожидалась «(» после $id');
      }
      final arg = parseAddSub();
      if (!match(')')) {
        throw const FormatException('Ожидалась «)»');
      }
      return FuncExpr(id, arg);
    }
    throw FormatException('Неожиданный символ: $c');
  }

  bool _isFunc(String id) {
    return const {
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'sqrt',
      'ln',
      'log',
    }.contains(id);
  }

  double _readNumber() {
    final start = pos;
    while (pos < src.length && (_isDigit(src[pos]) || src[pos] == '.' || src[pos] == ',')) {
      pos++;
    }
    if (start == pos) {
      throw const FormatException('Ожидалось число');
    }
    final raw = src.substring(start, pos).replaceAll(',', '.');
    return double.parse(raw);
  }

  String _readIdent() {
    final start = pos;
    while (pos < src.length && (_isLetter(src[pos]) || _isDigit(src[pos]))) {
      pos++;
    }
    return src.substring(start, pos);
  }

  static bool _isDigit(String c) => c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  static bool _isLetter(String c) {
    if (c.isEmpty) return false;
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122);
  }
}
