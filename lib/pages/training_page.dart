import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_provider.dart';
import '../models/workout.dart';
import '../models/template.dart';
import '../models/template_item.dart';
import '../widgets/workout_card.dart';
import 'session_page.dart';
import 'workout_detail_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  List<Workout> _recentWorkouts = [];
  int _totalWorkouts = 0;
  double _totalVolume = 0;
  int _streak = 0;
  bool _isKg = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final prefs = await SharedPreferences.getInstance();
    final workouts = await sp.workoutService.getRecentWorkouts(limit: 5);
    final total = await sp.statsRepository.getTotalWorkouts();
    final volume = await sp.statsRepository.getTotalVolume();
    final streak = await sp.statsRepository.getCurrentStreak();
    final isKg = prefs.getString('weight_unit') != 'lb';

    if (mounted) {
      setState(() {
        _recentWorkouts = workouts;
        _totalWorkouts = total;
        _totalVolume = volume;
        _streak = streak;
        _isKg = isKg;
      });
    }
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TemplateSelectorSheet(
        onStartBlank: () {
          Navigator.pop(context);
          _startWorkout(null, null);
        },
        onSelectTemplate: (template, items) {
          Navigator.pop(context);
          _startWorkout(template, items);
        },
      ),
    );
  }

  Future<void> _startWorkout(
      Template? template, List<TemplateItem>? items) async {
    final sp = ServiceProvider.of(context);
    final workoutId = await sp.workoutService.startWorkout(
      templateName: template?.nameZh,
    );

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionPage(
            workoutId: workoutId,
            templateItems: items,
          ),
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unit = _isKg ? 'kg' : 'lb';
    final displayVolume = _isKg ? _totalVolume : _totalVolume * 2.20462;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatsCard(
                    title: l10n.totalWorkouts,
                    value: '$_totalWorkouts',
                    icon: Icons.fitness_center,
                  ),
                  const SizedBox(width: 8),
                  _StatsCard(
                    title: l10n.totalVolume,
                    value: '${(displayVolume / 1000).toStringAsFixed(1)}t',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  const SizedBox(width: 8),
                  _StatsCard(
                    title: l10n.currentStreak,
                    value: '$_streak ${l10n.week}',
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: _showTemplateSelector,
                icon: const Icon(Icons.add),
                label: Text(l10n.startWorkout),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
            if (_recentWorkouts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(l10n.recentWorkouts,
                    style: theme.textTheme.titleMedium),
              ),
              ..._recentWorkouts.map((w) => WorkoutCard(
                    workout: w,
                    isKg: _isKg,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailPage(workoutId: w.id!),
                        ),
                      );
                      _loadData();
                    },
                  )),
            ] else
              Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(l10n.noWorkouts,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    const SizedBox(height: 8),
                    Text(l10n.noWorkoutsHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(height: 4),
              Text(value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(title,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateSelectorSheet extends StatefulWidget {
  final VoidCallback onStartBlank;
  final void Function(Template template, List<TemplateItem> items)
      onSelectTemplate;

  const _TemplateSelectorSheet({
    required this.onStartBlank,
    required this.onSelectTemplate,
  });

  @override
  State<_TemplateSelectorSheet> createState() => _TemplateSelectorSheetState();
}

class _TemplateSelectorSheetState extends State<_TemplateSelectorSheet> {
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

  Future<void> _selectTemplate(Template template) async {
    final sp = ServiceProvider.of(context);
    final items = await sp.templateRepository.getTemplateItems(template.id!);
    widget.onSelectTemplate(template, items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(l10n.chooseTemplate,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: widget.onStartBlank,
                icon: const Icon(Icons.add),
                label: Text(l10n.startBlankWorkout),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.threeDaySplit,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._threeDayTemplates.map((t) => Card(
                    child: ListTile(
                      title: Text(t.nameZh),
                      subtitle: t.nameEn != null ? Text(t.nameEn!) : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTemplate(t),
                    ),
                  )),
              const SizedBox(height: 16),
              Text(l10n.fiveDaySplit,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._fiveDayTemplates.map((t) => Card(
                    child: ListTile(
                      title: Text(t.nameZh),
                      subtitle: t.nameEn != null ? Text(t.nameEn!) : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTemplate(t),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
