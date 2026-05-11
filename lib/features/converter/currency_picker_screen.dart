import 'package:flutter/material.dart';

import '../../core/currencies_data.dart';

String _sectionLetterRu(String nameRu) {
  if (nameRu.isEmpty) return '#';
  return nameRu[0].toUpperCase();
}

class CurrencyPickerScreen extends StatelessWidget {
  const CurrencyPickerScreen({super.key, required this.selectedCode});

  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    final popular = kAllCurrencies.where((c) => c.popular).toList();
    final rest = kAllCurrencies.where((c) => !c.popular).toList()
      ..sort((a, b) => a.nameRu.compareTo(b.nameRu));

    final grouped = <String, List<CurrencyInfo>>{};
    for (final c in rest) {
      final k = _sectionLetterRu(c.nameRu);
      grouped.putIfAbsent(k, () => []).add(c);
    }
    final letters = grouped.keys.toList()..sort();

    final children = <Widget>[
      const _SectionHeader('Популярные валюты'),
      ...popular.map((c) => _tile(context, c)),
      for (final L in letters) ...[
        _SectionHeader(L, dense: true),
        ...grouped[L]!.map((c) => _tile(context, c)),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите валюту'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch<String?>(
                context: context,
                delegate: _CurrencySearchDelegate(),
              ).then((code) {
                if (code != null && context.mounted) {
                  Navigator.of(context).pop(code);
                }
              });
            },
          ),
        ],
      ),
      body: ListView(children: children),
    );
  }

  Widget _tile(BuildContext context, CurrencyInfo c) {
    final sel = c.code == selectedCode;
    return ListTile(
      title: Text(c.nameRu, style: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
      trailing: Text(c.code, style: TextStyle(color: Colors.grey.shade600)),
      onTap: () => Navigator.of(context).pop(c.code),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.dense = false});
  final String text;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, dense ? 8 : 16, 16, dense ? 4 : 8),
      child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: dense ? 15 : 13, fontWeight: dense ? FontWeight.w700 : FontWeight.w500)),
    );
  }
}

class _CurrencySearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final list = kAllCurrencies
        .where(
          (c) => q.isEmpty || c.code.toLowerCase().contains(q) || c.nameRu.toLowerCase().contains(q),
        )
        .toList();
    return ListView(
      children: list
          .map(
            (c) => ListTile(
              title: Text(c.nameRu),
              trailing: Text(c.code),
              onTap: () => close(context, c.code),
            ),
          )
          .toList(),
    );
  }
}
