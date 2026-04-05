import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/service_locator.dart';
import '../theme/app_colors.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage>
    with AutomaticKeepAliveClientMixin {
  bool _isKg = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isKg = prefs.getString('weight_unit') != 'lb';
    });
  }

  Future<void> _setWeightUnit(bool isKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_unit', isKg ? 'kg' : 'lb');
    setState(() => _isKg = isKg);
  }

  Future<void> _replayTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorial_done');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重启应用即可看到教程')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final localeService = ServiceLocator.of(context).localeService;
    final isZh = localeService.isZh;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageTitle)),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ── 语言 ──────────────────────────────────
          _SectionHeader(l10n.language),
          _SegmentedTile(
            options: [l10n.languageZh, l10n.languageEn],
            selectedIndex: isZh ? 0 : 1,
            onChanged: (i) => localeService.setLocale(i == 0 ? 'zh' : 'en'),
          ),

          // ── 重量单位 ──────────────────────────────
          _SectionHeader(l10n.weightUnit),
          _SegmentedTile(
            options: [l10n.kg, l10n.lb],
            selectedIndex: _isKg ? 0 : 1,
            onChanged: (i) => _setWeightUnit(i == 0),
          ),

          // ── 其他 ──────────────────────────────────
          _SectionHeader(''),
          ListTile(
            leading: const Icon(Icons.play_circle_outline, color: AppColors.primary),
            title: Text(l10n.replayTutorial),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: _replayTutorial,
          ),
          ListTile(
            leading: const Icon(Icons.view_list, color: AppColors.primary),
            title: Text(l10n.templates),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {
              // TODO: 跳转到模板管理页（Phase 2）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('模板管理 - 即将推出')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
            title: Text(l10n.about),
            subtitle: Text(l10n.version('1.0.0')),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'RepLog',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 RepLog',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SegmentedTile extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedTile({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SegmentedButton<int>(
        segments: options
            .asMap()
            .entries
            .map((e) => ButtonSegment<int>(value: e.key, label: Text(e.value)))
            .toList(),
        selected: {selectedIndex},
        onSelectionChanged: (s) => onChanged(s.first),
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }
}
