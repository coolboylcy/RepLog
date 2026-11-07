import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<Locale> localeNotifier;

  const SettingsPage({super.key, required this.localeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _weightUnit = 'kg';
  String _language = 'zh';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightUnit = prefs.getString('weight_unit') ?? 'kg';
      _language = prefs.getString('language') ?? 'zh';
    });
  }

  Future<void> _setWeightUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_unit', unit);
    setState(() => _weightUnit = unit);
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    widget.localeNotifier.value = Locale(lang);
    setState(() => _language = lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.weightUnit, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.kg),
                  value: 'kg',
                  groupValue: _weightUnit,
                  onChanged: (v) => _setWeightUnit(v!),
                ),
                RadioListTile<String>(
                  title: Text(l10n.lb),
                  value: 'lb',
                  groupValue: _weightUnit,
                  onChanged: (v) => _setWeightUnit(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.language, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.chinese),
                  value: 'zh',
                  groupValue: _language,
                  onChanged: (v) => _setLanguage(v!),
                ),
                RadioListTile<String>(
                  title: Text(l10n.english),
                  value: 'en',
                  groupValue: _language,
                  onChanged: (v) => _setLanguage(v!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
