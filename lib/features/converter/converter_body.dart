import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/currency_service.dart';
import '../../widgets/scale_calc_button.dart';
import 'currency_picker_screen.dart';

class ConverterBody extends StatefulWidget {
  const ConverterBody({super.key});

  @override
  State<ConverterBody> createState() => _ConverterBodyState();
}

class _ConverterBodyState extends State<ConverterBody> {
  final _svc = CurrencyService();
  String _from = 'USD';
  String _to = 'RUB';
  String _input = '1';
  double? _rate;
  DateTime? _fetched;
  String? _err;
  bool _busy = false;

  static const _accent = Color(0xFFE53935);
  static const _opBg = Color(0xFFFFE8E8);
  static const _numBg = Color(0xFFECECEC);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final r = await _svc.fetchPair(from: _from, to: _to);
      if (!mounted) return;
      setState(() {
        _rate = r.rate;
        _fetched = r.fetched;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _rate = null;
        _err = 'Не удалось загрузить курс';
        _busy = false;
      });
    }
  }

  double? _amount() {
    final s = _input.replaceAll(',', '.');
    if (s.isEmpty || s == '.' || s == '-') return null;
    return double.tryParse(s);
  }

  String _converted() {
    final a = _amount();
    final r = _rate;
    if (a == null || r == null) return '—';
    final v = a * r;
    return NumberFormat.decimalPattern('ru_RU').format(v);
  }

  Future<void> _pick(bool from) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CurrencyPickerScreen(selectedCode: from ? _from : _to),
      ),
    );
    if (code == null || !mounted) return;
    setState(() {
      if (from) {
        _from = code;
      } else {
        _to = code;
      }
    });
    await _load();
  }

  Future<void> _swapCurrencies() async {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
    await _load();
  }

  void _negateAmount() {
    setState(() {
      if (_input.startsWith('-')) {
        _input = _input.substring(1);
        if (_input.isEmpty || _input == ',') {
          _input = '0';
        }
      } else if (_input != '0') {
        _input = '-$_input';
      }
    });
  }

  Widget _emptyPad() {
    return const Padding(
      padding: EdgeInsets.all(4),
      child: SizedBox.expand(),
    );
  }

  void _key(String t) {
    setState(() {
      if (t == 'AC') {
        _input = '0';
        return;
      }
      if (t == '⌫') {
        if (_input.length <= 1) {
          _input = '0';
        } else {
          _input = _input.substring(0, _input.length - 1);
        }
        return;
      }
      if (t == ',') {
        if (_input.contains(',')) return;
        if (_input.isEmpty) _input = '0';
        _input += ',';
        return;
      }
      if (t == '00') {
        if (_input == '0') return;
        _input += '00';
        return;
      }
      if (t.length == 1 && t.codeUnitAt(0) >= 48 && t.codeUnitAt(0) <= 57) {
        if (_input == '0' && t != '0') {
          _input = t;
        } else if (_input == '0' && t == '0') {
          return;
        } else {
          _input += t;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fromInfo = _svc.byCode(_from);
    final toInfo = _svc.byCode(_to);
    final meta = _fetched != null
        ? 'Источник данных: Frankfurter. Последнее обновление: ${DateFormat.yMMMd('ru_RU').add_Hms().format(_fetched!)}'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Конвертация ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('валют', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          Container(height: 3, width: 40, color: _accent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CurrencyRow(
            label: fromInfo != null ? '${fromInfo.nameRu} ${fromInfo.code}' : _from,
            value: _input,
            onTap: () => _pick(true),
          ),
          const Divider(height: 1),
          _CurrencyRow(
            label: toInfo != null ? '${toInfo.nameRu} ${toInfo.code}' : _to,
            value: _converted(),
            onTap: () => _pick(false),
            mutedValue: true,
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_err!, style: const TextStyle(color: _accent, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(meta, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.05,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _b(context, 'AC', () => _key('AC'), fg: _accent, bg: _opBg),
                _b(context, '', () => _key('⌫'), fg: _accent, bg: _opBg, icon: Icons.backspace_outlined),
                _b(context, '', () => _load(), fg: Colors.white, bg: _accent, icon: Icons.refresh),
                _b(context, '', () => _swapCurrencies(), fg: _accent, bg: _opBg, icon: Icons.swap_vert),
                _b(context, '7', () => _key('7')),
                _b(context, '8', () => _key('8')),
                _b(context, '9', () => _key('9')),
                _b(context, '±', _negateAmount, fg: _accent, bg: _opBg),
                _b(context, '4', () => _key('4')),
                _b(context, '5', () => _key('5')),
                _b(context, '6', () => _key('6')),
                _emptyPad(),
                _b(context, '1', () => _key('1')),
                _b(context, '2', () => _key('2')),
                _b(context, '3', () => _key('3')),
                _emptyPad(),
                _b(context, '00', () => _key('00')),
                _b(context, '0', () => _key('0')),
                _b(context, ',', () => _key(',')),
                _b(context, '=', () => _load(), fg: Colors.white, bg: _accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _b(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    Color? fg,
    Color? bg,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ScaleCalcButton(
        label: label,
        foreground: fg,
        background: bg ?? _numBg,
        onTap: onTap,
        child: icon != null ? Icon(icon, color: fg ?? Colors.black87, size: 22) : null,
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.mutedValue = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool mutedValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: mutedValue ? Colors.black38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}