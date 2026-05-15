import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/calculator_controller.dart';
import '../../core/display_math.dart';
import '../../widgets/scale_calc_button.dart';

class CalculatorBody extends StatelessWidget {
  const CalculatorBody({super.key});

  static const _accent = Color(0xFFE53935);
  static const _opBg = Color(0xFFFFE8E8);
  static const _numBg = Color(0xFFECECEC);
  static const _memBg = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Display(calc: calc),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: 'История',
                onPressed: () async {
                  await calc.feedbackTap();
                  calc.toggleHistory();
                },
                icon: Icon(
                  Icons.history,
                  color: calc.historyVisible ? _accent : Colors.black54,
                ),
              ),
              IconButton(
                tooltip: calc.scientificMode ? 'Обычные клавиши' : 'Научные функции',
                onPressed: () async {
                  await calc.feedbackTap();
                  calc.toggleScientific();
                },
                icon: Icon(
                  Icons.functions,
                  color: calc.scientificMode ? _accent : Colors.black54,
                ),
              ),
              if (calc.scientificMode) ...[
                TextButton(
                  onPressed: () async {
                    await calc.feedbackTap();
                    calc.toggleAngleUnit();
                  },
                  child: Text(
                    calc.angleInDegrees ? 'Deg' : 'Rad',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: _accent),
                  ),
                ),
              ],
            ],
          ),
          // Фиксированная высота для научной панели — не сдвигает грид
          SizedBox(
            height: calc.scientificMode ? 44 : 0,
            child: calc.scientificMode ? _SciStrip(calc: calc) : null,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: calc.historyVisible ? _HistoryPanel(calc: calc) : const _MainPad(),
          ),
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.calc});
  final CalculatorController calc;

  @override
  Widget build(BuildContext context) {
    const accent = CalculatorBody._accent;
    final pendingOp = DisplayMath.trailingOperator(calc.expression);
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  calc.expression.isEmpty ? ' ' : calc.expression,
                  key: ValueKey(calc.expression),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 22, color: Colors.black45, height: 1.1),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: Text(
                  calc.error ?? (calc.result.isEmpty ? ' ' : calc.result),
                  key: ValueKey('${calc.result}_${calc.error}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: calc.error != null ? accent : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (pendingOp != null && calc.error == null)
            Positioned(
              top: 0,
              right: 0,
              child: Text(pendingOp, style: const TextStyle(fontSize: 18, color: accent, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _SciStrip extends StatelessWidget {
  const _SciStrip({required this.calc});
  final CalculatorController calc;

  @override
  Widget build(BuildContext context) {
    final chips = <(String label, String ins, bool plain)>[
      ('sin(', 'sin(', false),
      ('cos(', 'cos(', false),
      ('tan(', 'tan(', false),
      ('√', 'sqrt(', false),
      ('ln(', 'ln(', false),
      ('log(', 'log(', false),
      ('^', '^', true),
      ('(', '(', false),
      (')', ')', true),
      ('π', 'pi', false),
      ('e', 'e', false),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: chips.length,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final c = chips[i];
        return ActionChip(
          label: Text(c.$1),
          onPressed: () async {
            await calc.feedbackTap();
            if (c.$3) {
              calc.append(c.$2);
            } else {
              calc.appendSci(c.$2);
            }
          },
          backgroundColor: CalculatorBody._memBg,
          side: BorderSide.none,
        );
      },
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.calc});
  final CalculatorController calc;

  @override
  Widget build(BuildContext context) {
    const accent = CalculatorBody._accent;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Сегодня',
                style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: calc.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('История отсутствует', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: calc.history.length,
                    itemBuilder: (_, i) {
                      final h = calc.history[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.expression, style: const TextStyle(color: Colors.black54, fontSize: 16)),
                            Text('=${h.result}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                            const Divider(height: 1),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          TextButton(
            onPressed: calc.history.isEmpty
                ? null
                : () async {
                    await calc.feedbackTap();
                    calc.clearHistory();
                  },
            child: Text(
              'Очистить историю',
              style: TextStyle(color: calc.history.isEmpty ? Colors.black26 : accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainPad extends StatelessWidget {
  const _MainPad({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorController>();

    const memBg = CalculatorBody._memBg;
    const numBg = CalculatorBody._numBg;
    const accent = CalculatorBody._accent;
    const opBg = CalculatorBody._opBg;

    Future<void> a(String t) async {
      await calc.feedbackTap();
      calc.append(t);
    }

    Widget cell(Widget w) => Padding(padding: const EdgeInsets.all(5), child: w);

    final children = <Widget>[
      cell(ScaleCalcButton(label: 'mc', onTap: () async { await calc.feedbackTap(); calc.memoryClear(); }, background: memBg, foreground: Colors.black54, fontSize: 16)),
      cell(ScaleCalcButton(label: 'm+', onTap: () async { await calc.feedbackTap(); calc.memoryAdd(); }, background: memBg, foreground: Colors.black54, fontSize: 16)),
      cell(ScaleCalcButton(label: 'm−', onTap: () async { await calc.feedbackTap(); calc.memorySubtract(); }, background: memBg, foreground: Colors.black54, fontSize: 16)),
      cell(ScaleCalcButton(label: 'mr', onTap: () async { await calc.feedbackTap(); calc.memoryRecall(); }, background: memBg, foreground: Colors.black54, fontSize: 16)),
      cell(ScaleCalcButton(label: 'AC', onTap: () async { await calc.feedbackTap(); calc.clearAll(); }, background: numBg, foreground: accent, fontSize: 18)),
      cell(ScaleCalcButton(
        label: '',
        onTap: () async { await calc.feedbackTap(); calc.backspace(); },
        background: numBg,
        child: const Icon(Icons.backspace_outlined, color: accent),
      )),
      cell(ScaleCalcButton(label: '±', onTap: () async { await calc.feedbackTap(); calc.negate(); }, background: numBg, foreground: accent)),
      cell(ScaleCalcButton(label: '÷', onTap: () => a('÷'), background: opBg, foreground: accent)),
      ...['7', '8', '9'].map((d) => cell(ScaleCalcButton(label: d, onTap: () => a(d), background: numBg))),
      cell(ScaleCalcButton(label: '×', onTap: () => a('×'), background: opBg, foreground: accent)),
      ...['4', '5', '6'].map((d) => cell(ScaleCalcButton(label: d, onTap: () => a(d), background: numBg))),
      cell(ScaleCalcButton(label: '−', onTap: () => a('-'), background: opBg, foreground: accent)),
      ...['1', '2', '3'].map((d) => cell(ScaleCalcButton(label: d, onTap: () => a(d), background: numBg))),
      cell(ScaleCalcButton(label: '+', onTap: () => a('+'), background: opBg, foreground: accent)),
      cell(ScaleCalcButton(label: '%', onTap: () => a('%'), background: numBg)),
      cell(ScaleCalcButton(label: '0', onTap: () => a('0'), background: numBg)),
      cell(ScaleCalcButton(label: ',', onTap: () => a(','), background: numBg)),
      cell(ScaleCalcButton(label: '=', onTap: () async { await calc.feedbackTap(); calc.submit(); }, background: accent, foreground: Colors.white, fontSize: 26)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      // NeverScrollableScrollPhysics чтобы грид не прыгал
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: children,
    );
  }
}
