import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_settings.dart';
import 'percent_mode_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Звук нажатия кнопок', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: settings.soundOn,
                  activeThumbColor: const Color(0xFFE53935),
                  activeTrackColor: const Color(0xFFEF9A9A),
                  onChanged: settings.setSound,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Режим добавления/вычитания процентов',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Проценты можно преобразовать в десятичные значения или пропорции для добавления или вычитания.\n'
                    'Сейчас: ${settings.percentModeLabelRu()}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PercentModeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Проверить наличие обновлений', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text('V1.0.0', style: TextStyle(color: Colors.grey.shade600)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('У вас последняя версия из этого репозитория.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Заявление о ПО с открытым исходным кодом', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Открытое ПО'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'Приложение использует Flutter SDK и пакеты из pub.dev на условиях их лицензий '
                            '(BSD, MIT и др.). Иконки и шрифты — стандартные Material.',
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
