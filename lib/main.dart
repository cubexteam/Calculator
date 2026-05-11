import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_settings.dart';
import 'core/calculator_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettings>.value(value: settings),
        ChangeNotifierProvider<CalculatorController>(
          create: (ctx) => CalculatorController(settings: ctx.read<AppSettings>()),
        ),
      ],
      child: const CalculatorApp(),
    ),
  );
}