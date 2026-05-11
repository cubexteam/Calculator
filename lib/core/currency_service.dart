import 'dart:convert';

import 'package:http/http.dart' as http;

import 'currencies_data.dart';

/// Курсы через Frankfurter (без ключа, HTTPS).
class CurrencyService {
  Future<({double rate, DateTime fetched})> fetchPair({
    required String from,
    required String to,
  }) async {
    if (from == to) {
      return (rate: 1, fetched: DateTime.now());
    }
    final uri = Uri.parse(
      'https://api.frankfurter.app/latest?from=$from&to=$to',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final rates = map['rates'] as Map<String, dynamic>?;
    if (rates == null || !rates.containsKey(to)) {
      throw Exception('Нет курса для $to');
    }
    final r = (rates[to] as num).toDouble();
    return (rate: r, fetched: DateTime.now());
  }

  CurrencyInfo? byCode(String code) {
    for (final c in kAllCurrencies) {
      if (c.code == code) return c;
    }
    return null;
  }
}
