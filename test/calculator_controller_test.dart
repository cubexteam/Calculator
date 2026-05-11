import 'package:calculator/core/app_settings.dart';
import 'package:calculator/core/calculator_controller.dart';
import 'package:calculator/core/expression_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('5÷5 = 1 и оператор после результата подставляет прошлое значение', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings();
    await settings.load();
    final c = CalculatorController(settings: settings);
    c.append('5');
    c.append('÷');
    c.append('5');
    c.submit();
    expect(c.result.replaceAll(',', '.'), '1');
    c.append('+');
    c.append('2');
    expect(c.expression, '1+2');
    c.dispose();
  });

  test('режим пропорции: предпросчёт 100+20% → 120', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'key_percent_mode': 'proportion',
    });
    final settings = AppSettings();
    await settings.load();
    expect(settings.percentMode, PercentMode.proportion);
    final c = CalculatorController(settings: settings);
    c.append('100');
    c.append('+');
    c.append('20');
    c.append('%');
    expect(double.tryParse(c.result.replaceAll(',', '.').replaceAll(' ', '')), closeTo(120, 1e-6));
    c.dispose();
  });
}
