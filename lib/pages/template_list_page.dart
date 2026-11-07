import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../di/service_provider.dart';
import '../models/template.dart';
import 'template_detail_page.dart';

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  List<Template> _threeDayTemplates = [];
  List<Template> _fiveDayTemplates = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final sp = ServiceProvider.of(context);
    final three =
        await sp.templateRepository.getTemplatesBySplitType('three_day');
    final five =
        await sp.templateRepository.getTemplatesBySplitType('five_day');
    if (mounted) {
      setState(() {
        _threeDayTemplates = three;
        _fiveDayTemplates = five;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templates),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.threeDaySplit,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._threeDayTemplates.map((t) => Card(
                child: ListTile(
                  title: Text(t.nameZh),
                  subtitle: t.nameEn != null ? Text(t.nameEn!) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TemplateDetailPage(templateId: t.id!),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 24),
          Text(l10n.fiveDaySplit,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._fiveDayTemplates.map((t) => Card(
                child: ListTile(
                  title: Text(t.nameZh),
                  subtitle: t.nameEn != null ? Text(t.nameEn!) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TemplateDetailPage(templateId: t.id!),
                      ),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}
