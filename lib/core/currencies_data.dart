/// Справочник валют (русские названия + ISO). Популярные — первый блок как на скрине.
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.nameRu,
    this.popular = false,
  });
  final String code;
  final String nameRu;
  final bool popular;
}

const List<CurrencyInfo> kAllCurrencies = [
  CurrencyInfo(code: 'CNY', nameRu: 'Китайский юань', popular: true),
  CurrencyInfo(code: 'USD', nameRu: 'Доллар США', popular: true),
  CurrencyInfo(code: 'JPY', nameRu: 'Японская иена', popular: true),
  CurrencyInfo(code: 'KRW', nameRu: 'Южнокорейская вона', popular: true),
  CurrencyInfo(code: 'HKD', nameRu: 'Гонконгский доллар', popular: true),
  CurrencyInfo(code: 'MOP', nameRu: 'Патака Макао', popular: true),
  CurrencyInfo(code: 'GBP', nameRu: 'Британский фунт', popular: true),
  CurrencyInfo(code: 'EUR', nameRu: 'Евро', popular: true),
  CurrencyInfo(code: 'AUD', nameRu: 'Австралийский доллар', popular: true),
  CurrencyInfo(code: 'RUB', nameRu: 'Российский рубль', popular: true),
  CurrencyInfo(code: 'CHF', nameRu: 'Швейцарский франк'),
  CurrencyInfo(code: 'CAD', nameRu: 'Канадский доллар'),
  CurrencyInfo(code: 'SEK', nameRu: 'Шведская крона'),
  CurrencyInfo(code: 'NOK', nameRu: 'Норвежская крона'),
  CurrencyInfo(code: 'PLN', nameRu: 'Польский злотый'),
  CurrencyInfo(code: 'TRY', nameRu: 'Турецкая лира'),
  CurrencyInfo(code: 'INR', nameRu: 'Индийская рупия'),
  CurrencyInfo(code: 'BRL', nameRu: 'Бразильский реал'),
  CurrencyInfo(code: 'ZAR', nameRu: 'Южноафриканский рэнд'),
  CurrencyInfo(code: 'AED', nameRu: 'Дирхам ОАЭ'),
  CurrencyInfo(code: 'SGD', nameRu: 'Сингапурский доллар'),
  CurrencyInfo(code: 'NZD', nameRu: 'Новозеландский доллар'),
  CurrencyInfo(code: 'MXN', nameRu: 'Мексиканское песо'),
  CurrencyInfo(code: 'ALL', nameRu: 'Албанский лек'),
  CurrencyInfo(code: 'AZN', nameRu: 'Азербайджанский манат'),
  CurrencyInfo(code: 'AMD', nameRu: 'Армянский драм'),
  CurrencyInfo(code: 'BYN', nameRu: 'Белорусский рубль'),
  CurrencyInfo(code: 'BGN', nameRu: 'Болгарский лев'),
  CurrencyInfo(code: 'HUF', nameRu: 'Венгерский форинт'),
  CurrencyInfo(code: 'DKK', nameRu: 'Датская крона'),
  CurrencyInfo(code: 'EGP', nameRu: 'Египетский фунт'),
  CurrencyInfo(code: 'ILS', nameRu: 'Новый израильский шекель'),
  CurrencyInfo(code: 'IDR', nameRu: 'Индонезийская рупия'),
  CurrencyInfo(code: 'ISK', nameRu: 'Исландская крона'),
  CurrencyInfo(code: 'KZT', nameRu: 'Казахстанский тенге'),
  CurrencyInfo(code: 'QAR', nameRu: 'Катарский риял'),
  CurrencyInfo(code: 'MYR', nameRu: 'Малайзийский ринггит'),
  CurrencyInfo(code: 'RON', nameRu: 'Румынский лей'),
  CurrencyInfo(code: 'SAR', nameRu: 'Саудовский риял'),
  CurrencyInfo(code: 'THB', nameRu: 'Тайский бат'),
  CurrencyInfo(code: 'TWD', nameRu: 'Тайваньский доллар'),
  CurrencyInfo(code: 'UAH', nameRu: 'Украинская гривна'),
  CurrencyInfo(code: 'CZK', nameRu: 'Чешская крона'),
  CurrencyInfo(code: 'CLP', nameRu: 'Чилийское песо'),
];
