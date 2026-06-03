import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../models/template.dart';
import '../theme/app_colors.dart';
import 'template_detail_page.dart';

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  List<Template> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ServiceLocator.of(context).templateRepository;
    final all = await repo.getAll();
    if (mounted) {
      setState(() {
        _templates = all;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final threeDay =
        _templates.where((t) => t.splitType == 'three_day').toList();
    final fiveDay = _templates.where((t) => t.splitType == 'five_day').toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templates)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (threeDay.isNotEmpty) ...[
                  _SectionHeader(
                      label: l10n.splitThreeDay, color: AppColors.primary),
                  ...threeDay.map((t) => _TemplateTile(
                        template: t,
                        locale: locale,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemplateDetailPage(template: t),
                          ),
                        ),
                      )),
                ],
                if (fiveDay.isNotEmpty) ...[
                  _SectionHeader(
                      label: l10n.splitFiveDay, color: AppColors.accent),
                  ...fiveDay.map((t) => _TemplateTile(
                        template: t,
                        locale: locale,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemplateDetailPage(template: t),
                          ),
                        ),
                      )),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final Template template;
  final String locale;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = template.splitType == 'three_day'
        ? AppColors.primary
        : AppColors.accent;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            template.dayLabel ?? '?',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      title: Text(template.localizedName(locale),
          style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
