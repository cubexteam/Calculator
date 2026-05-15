import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_settings.dart';
import '../../core/expression_parser.dart';

class PercentModeScreen extends StatelessWidget {
  const PercentModeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Режим добавления/вычитания процентов'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: settings.percentMode == PercentMode.numericalValue
                ? _ExampleCard(
                    key: const ValueKey('num'),
                    subtitle: 'Пример (Расчёт на основе числового значения)',
                    expr: '100+20%',
                    result: '100,2',
                    ruleParts: const [
                      _RulePart('Правила расчёта: 100+', false),
                      _RulePart('0,2', true),
                      _RulePart('=100,2', false),
                    ],
                  )
                : _ExampleCard(
                    key: const ValueKey('prop'),
                    subtitle: 'Пример (Расчёт в виде пропорции)',
                    expr: '100+20%',
                    result: '120',
                    ruleParts: const [
                      _RulePart('Правила расчёта: 100+', false),
                      _RulePart('(100×20%)', true),
                      _RulePart('=120', false),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _OptionTile(
                  title: 'Расчёт на основе числового значения',
                  subtitle:
                      'Преобразуйте проценты в десятичные значения для выполнения операций сложения и вычитания.',
                  selected: settings.percentMode == PercentMode.numericalValue,
                  onTap: () => settings.setPercentMode(PercentMode.numericalValue),
                ),
                const Divider(height: 1),
                _OptionTile(
                  title: 'Расчёт в виде пропорции',
                  subtitle:
                      'Проценты выражены в виде пропорции. Этот метод часто используется для расчёта скидок.',
                  selected: settings.percentMode == PercentMode.proportion,
                  onTap: () => settings.setPercentMode(PercentMode.proportion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? _accent : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _RulePart {
  const _RulePart(this.text, this.accent);
  final String text;
  final bool accent;
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    super.key,
    required this.subtitle,
    required this.expr,
    required this.result,
    required this.ruleParts,
  });

  final String subtitle;
  final String expr;
  final String result;
  final List<_RulePart> ruleParts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(expr,
                style: const TextStyle(fontSize: 22, color: Colors.black54)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(result,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text.rich(
              TextSpan(
                children: [
                  for (final p in ruleParts)
                    TextSpan(
                      text: p.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: p.accent ? const Color(0xFFE53935) : Colors.black54,
                        fontWeight:
                            p.accent ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
