import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const _pipChannel = MethodChannel('com.calculator.app/native');

  Future<void> _enterPip() async {
    try {
      await _pipChannel.invokeMethod<void>('enterPip');
    } on PlatformException {
      // Устройство не поддерживает PiP — молча игнорируем
    }
  }

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
                  // Кнопка свернуть в маленькое окно (PiP)
                  IconButton(
                    tooltip: 'Свернуть в окно',
                    onPressed: _enterPip,
                    icon: const _PipIcon(),
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

/// Иконка «уголок» — символ сворачивания в маленькое окно (как на скрине).
class _PipIcon extends StatelessWidget {
  const _PipIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _CornerPainter(color: Colors.black87),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final arm = w * 0.42; // длина плеча уголка

    // Верхний левый уголок
    canvas.drawLine(Offset(0, arm), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(arm, 0), paint);

    // Верхний правый уголок
    canvas.drawLine(Offset(w - arm, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, arm), paint);

    // Нижний левый уголок
    canvas.drawLine(Offset(0, h - arm), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(arm, h), paint);

    // Нижний правый уголок
    canvas.drawLine(Offset(w - arm, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - arm), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
