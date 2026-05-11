import 'package:calculator/app.dart';
import 'package:calculator/core/app_settings.dart';
import 'package:calculator/core/calculator_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings();
    await settings.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettings>.value(value: settings),
          ChangeNotifierProvider<CalculatorController>(
            create: (ctx) => CalculatorController(settings: ctx.read<AppSettings>()),
            dispose: (_, c) => c.dispose(),
          ),
        ],
        child: const CalculatorApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Вычислить'), findsOneWidget);
  });
}
