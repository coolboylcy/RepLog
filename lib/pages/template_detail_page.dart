import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../di/service_provider.dart';
import '../models/template.dart';
import '../models/template_item.dart';
import 'session_page.dart';

class TemplateDetailPage extends StatefulWidget {
  final int templateId;

  const TemplateDetailPage({super.key, required this.templateId});

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  Template? _template;
  List<TemplateItem> _items = [];

  static const _muscleGroupNames = {
    'chest': '胸',
    'back': '背',
    'shoulders': '肩',
    'legs': '腿',
    'arms': '手臂',
    'core': '核心',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final template =
        await sp.templateRepository.getTemplateById(widget.templateId);
    final items =
        await sp.templateRepository.getTemplateItems(widget.templateId);
    if (mounted) {
      setState(() {
        _template = template;
        _items = items;
      });
    }
  }

  Future<void> _startTraining() async {
    final sp = ServiceProvider.of(context);
    final workoutId = await sp.workoutService.startWorkout(
      templateName: _template?.nameZh,
    );
    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionPage(
            workoutId: workoutId,
            templateItems: _items,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_template == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_template!.nameZh),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final muscleLabel =
                    _muscleGroupNames[item.muscleGroup] ??
                        item.muscleGroup ??
                        '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.exerciseNameZh ?? ''),
                    subtitle: Text(
                        '${item.defaultSets} ${l10n.sets} × ${item.defaultReps} ${l10n.reps}'),
                    trailing: Chip(
                      label: Text(muscleLabel,
                          style: theme.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _startTraining,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.trainWithTemplate),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
