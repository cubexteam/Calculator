import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'app_settings.dart';
import 'expression_evaluator.dart';
import 'native_bridge.dart';

class HistoryItem {
  HistoryItem({required this.expression, required this.result});
  final String expression;
  final String result;
}

class CalculatorController extends ChangeNotifier {
  CalculatorController({required this.settings}) {
    settings.addListener(_onSettings);
  }

  final AppSettings settings;

  void _onSettings() {
    _updatePreview();
    notifyListeners();
  }

  @override
  void dispose() {
    settings.removeListener(_onSettings);
    super.dispose();
  }

  String expression = '';
  String result = '';
  String? error;
  bool angleInDegrees = true;
  bool scientificMode = false;
  bool historyVisible = false;
  final List<HistoryItem> history = [];

  double? _memory;
  bool _freshResult = false;
  double? _lastValue;

  static final NumberFormat _ru = NumberFormat.decimalPattern('ru_RU');

  Future<void> feedbackTap() async {
    if (settings.soundOn) {
      await NativeBridge.playClick();
    }
  }

  void toggleHistory() {
    historyVisible = !historyVisible;
    notifyListeners();
  }

  void toggleScientific() {
    scientificMode = !scientificMode;
    notifyListeners();
  }

  void toggleAngleUnit() {
    angleInDegrees = !angleInDegrees;
    notifyListeners();
  }

  void clearAll() {
    expression = '';
    result = '';
    error = null;
    _freshResult = false;
    _lastValue = null;
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  void backspace() {
    if (expression.isEmpty) return;
    expression = expression.substring(0, expression.length - 1);
    error = null;
    _freshResult = false;
    _updatePreview();
    notifyListeners();
  }

  void append(String token, {bool fromScientific = false}) {
    error = null;
    if (_freshResult) {
      if (_startsNewNumber(token)) {
        expression = token;
      } else if (_isOperatorToken(token) && _lastValue != null) {
        expression = '${_formatChain(_lastValue!)}$token';
      } else {
        expression = token;
      }
      result = '';
      _freshResult = false;
      if (!_percentAppendAllowed(token)) {
        notifyListeners();
        return;
      }
      _updatePreview();
      notifyListeners();
      return;
    }
    if (!_percentAppendAllowed(token)) {
      return;
    }
    expression += token;
    _updatePreview();
    notifyListeners();
  }

  /// Вставка функции/константы: при необходимости добавляет «×» (например 2π).
  void appendSci(String token) {
    error = null;
    if (_freshResult) {
      expression = token;
      result = '';
      _freshResult = false;
      _updatePreview();
      notifyListeners();
      return;
    }
    if (expression.isNotEmpty) {
      final last = expression[expression.length - 1];
      final needMul = _isDigit(last) || last == ')' || last == '%';
      if (needMul) {
        expression += '×';
      }
    }
    expression += token;
    _updatePreview();
    notifyListeners();
  }

  bool _percentAppendAllowed(String token) {
    if (token != '%' || expression.isEmpty) return true;
    final last = expression[expression.length - 1];
    if (last == '%' || last == '+' || last == '-' || last == '×' || last == '÷' || last == '(') {
      return false;
    }
    return true;
  }

  bool _isOperatorToken(String token) {
    return token == '+' || token == '-' || token == '×' || token == '÷';
  }

  String _formatChain(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v.toString().replaceAll('.', ',');
  }

  bool _startsNewNumber(String token) {
    if (token.length != 1) return false;
    final c = token[0];
    return (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == ',' || c == '.';
  }

  void negate() {
    error = null;
    if (expression.isEmpty) return;
    final i = _lastNumberStart();
    if (i < 0) return;
    final numStr = expression.substring(i);
    if (numStr.startsWith('-')) {
      expression = expression.substring(0, i) + numStr.substring(1);
    } else {
      expression = expression.substring(0, i) + '-$numStr';
    }
    _updatePreview();
    notifyListeners();
  }

  int _lastNumberStart() {
    var i = expression.length - 1;
    while (i >= 0 && (expression[i] == ',' || expression[i] == '.' || _isDigit(expression[i]))) {
      i--;
    }
    if (i >= 0 && expression[i] == '-') {
      i--;
    }
    return i + 1;
  }

  bool _isDigit(String c) => c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  void submit() {
    error = null;
    if (expression.isEmpty) return;
    final v = tryEvaluate(expression, settings.percentMode, angleInDegrees: angleInDegrees);
    if (v == null) {
      error = 'Ошибка';
      notifyListeners();
      return;
    }
    final resStr = _formatOut(v);
    history.insert(0, HistoryItem(expression: expression, result: resStr));
    if (history.length > 200) {
      history.removeLast();
    }
    result = resStr;
    _lastValue = v;
    _freshResult = true;
    notifyListeners();
  }

  void memoryClear() {
    _memory = null;
    notifyListeners();
  }

  void memoryRecall() {
    if (_memory == null) return;
    error = null;
    if (_freshResult) {
      expression = '';
      _freshResult = false;
    }
    final s = _formatOut(_memory!);
    expression += s;
    _updatePreview();
    notifyListeners();
  }

  void memoryAdd() {
    final v = tryEvaluate(expression, settings.percentMode, angleInDegrees: angleInDegrees);
    if (v == null) return;
    _memory = (_memory ?? 0) + v;
    notifyListeners();
  }

  void memorySubtract() {
    final v = tryEvaluate(expression, settings.percentMode, angleInDegrees: angleInDegrees);
    if (v == null) return;
    _memory = (_memory ?? 0) - v;
    notifyListeners();
  }

  void _updatePreview() {
    if (expression.isEmpty) {
      result = '';
      return;
    }
    final v = tryEvaluate(expression, settings.percentMode, angleInDegrees: angleInDegrees);
    result = v == null ? '' : _formatOut(v);
  }

  String _formatOut(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    if (v == 0) return '0';
    final a = v.abs();
    if (a >= 1e12 || (a < 1e-9 && a > 0)) {
      return v.toStringAsExponential(6).replaceAll('.', ',');
    }
    final s = _ru.format(v);
    return s;
  }
}