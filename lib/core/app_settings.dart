import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expression_parser.dart';

class AppSettings extends ChangeNotifier {
  static const _keySound = 'key_sound';
  static const _keyPercent = 'key_percent_mode';

  bool soundOn = true;
  PercentMode percentMode = PercentMode.numericalValue;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    soundOn = p.getBool(_keySound) ?? true;
    final pm = p.getString(_keyPercent);
    if (pm == 'proportion') {
      percentMode = PercentMode.proportion;
    } else {
      percentMode = PercentMode.numericalValue;
    }
    notifyListeners();
  }

  Future<void> setSound(bool v) async {
    soundOn = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keySound, v);
  }

  Future<void> setPercentMode(PercentMode v) async {
    percentMode = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _keyPercent,
      v == PercentMode.proportion ? 'proportion' : 'numerical',
    );
  }

  String percentModeLabelRu() {
    switch (percentMode) {
      case PercentMode.numericalValue:
        return 'Расчёт на основе числового значения';
      case PercentMode.proportion:
        return 'Расчёт в виде пропорции';
    }
  }
}
