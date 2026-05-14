import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/favorite_service.dart';
import '../services/history_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool embedded;
  final ValueNotifier<ThemeMode>? themeMode;
  const SettingsScreen({super.key, this.embedded = false, this.themeMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(AppConstants.prefsTheme);
    setState(() {
      _mode = v == 'dark'
          ? ThemeMode.dark
          : v == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
    });
  }

  Future<void> _setMode(ThemeMode m) async {
    setState(() => _mode = m);
    final p = await SharedPreferences.getInstance();
    await p.setString(
      AppConstants.prefsTheme,
      m == ThemeMode.dark ? 'dark' : (m == ThemeMode.light ? 'light' : 'system'),
    );
    widget.themeMode?.value = m;
    // Si embarqué, on récupère le notifier global via ancestor inheritance
    final n = _ThemeScope.of(context);
    n?.value = m;
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      children: [
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('Apparence'),
          subtitle: Text(_mode == ThemeMode.dark
              ? 'Sombre'
              : _mode == ThemeMode.light
                  ? 'Clair'
                  : 'Système'),
        ),
        RadioListTile<ThemeMode>(
          value: ThemeMode.system,
          // ignore: deprecated_member_use
          groupValue: _mode,
          // ignore: deprecated_member_use
          onChanged: (v) => _setMode(v!),
          title: const Text('Système'),
        ),
        RadioListTile<ThemeMode>(
          value: ThemeMode.light,
          // ignore: deprecated_member_use
          groupValue: _mode,
          // ignore: deprecated_member_use
          onChanged: (v) => _setMode(v!),
          title: const Text('Clair'),
        ),
        RadioListTile<ThemeMode>(
          value: ThemeMode.dark,
          // ignore: deprecated_member_use
          groupValue: _mode,
          // ignore: deprecated_member_use
          onChanged: (v) => _setMode(v!),
          title: const Text('Sombre'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Effacer les favoris'),
          onTap: () async {
            await FavoriteService.clear();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favoris effacés')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_toggle_off),
          title: const Text('Effacer l\'historique'),
          onTap: () async {
            await HistoryService.clear();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique effacé')),
              );
            }
          },
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('À propos'),
        ),
        ListTile(
          title: const Text('Concepteur'),
          subtitle: const Text(AppConstants.designer),
          leading: const Icon(Icons.person),
        ),
        ListTile(
          title: const Text('Email'),
          subtitle: const Text(AppConstants.email),
          leading: const Icon(Icons.email),
        ),
        ListTile(
          title: const Text('Téléphone'),
          subtitle: const Text(AppConstants.phone),
          leading: const Icon(Icons.phone),
        ),
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
          leading: Icon(Icons.tag),
        ),
        const SizedBox(height: 24),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Paramètres')), body: body);
  }
}

/// Permet à un écran embarqué de retrouver le ValueNotifier<ThemeMode>.
class _ThemeScope extends InheritedWidget {
  final ValueNotifier<ThemeMode> notifier;
  const _ThemeScope({required this.notifier, required super.child});

  static ValueNotifier<ThemeMode>? of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<_ThemeScope>()?.notifier;

  @override
  bool updateShouldNotify(_ThemeScope old) => old.notifier != notifier;
}

class ThemeScope extends StatelessWidget {
  final ValueNotifier<ThemeMode> notifier;
  final Widget child;
  const ThemeScope({super.key, required this.notifier, required this.child});

  @override
  Widget build(BuildContext context) =>
      _ThemeScope(notifier: notifier, child: child);
}
