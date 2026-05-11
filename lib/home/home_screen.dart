import 'package:flutter/material.dart';
import '../features/calculator/calculator_body.dart';
import '../features/converter/converter_body.dart';
import '../features/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE53935);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tab,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black38,
                      indicatorColor: accent,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                      tabs: const [
                        Tab(text: 'Вычислить'),
                        Tab(text: 'Конвертер'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Дополнительно',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Дополнительные окна — по желанию можно расширить.')),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.black87),
                  ),
                  IconButton(
                    tooltip: 'Настройки',
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder<void>(
                          pageBuilder: (_, __, ___) => const SettingsScreen(),
                          transitionsBuilder: (_, anim, __, child) {
                            return FadeTransition(opacity: anim, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  CalculatorBody(),
                  ConverterBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
