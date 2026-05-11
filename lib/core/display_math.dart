import 'expression_evaluator.dart';
import 'expression_parser.dart';

/// Утилиты отображения: подсказка «текущая операция» и безопасный предпросчёт.
class DisplayMath {
  DisplayMath._();

  /// Последний символ выражения, если это бинарный оператор для подсветки в UI.
  static String? trailingOperator(String expression) {
    if (expression.isEmpty) return null;
    final last = expression[expression.length - 1];
    switch (last) {
      case '÷':
        return '÷';
      case '×':
        return '×';
      case '+':
        return '+';
      case '-':
      case '−':
        return '−';
      default:
        return null;
    }
  }

  /// Предпросчёт для строки на экране (с учётом режима % и углов).
  static double? preview(
    String expression,
    PercentMode percentMode, {
    bool angleInDegrees = false,
  }) {
    return tryEvaluate(expression, percentMode, angleInDegrees: angleInDegrees);
  }
}
