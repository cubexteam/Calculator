import 'package:flutter/services.dart';

/// Вызов Java {@link com.calculator.app.MainActivity} — короткий звук клавиши.
class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.calculator.app/native');

  static Future<void> playClick() async {
    try {
      await _channel.invokeMethod<void>('playClick');
    } on PlatformException {
      // Игнорируем — эмулятор без ToneGenerator и т.п.
    }
  }
}
