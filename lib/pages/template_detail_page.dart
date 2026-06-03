import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../models/exercise.dart';
import '../models/template.dart';
import '../models/template_item.dart';
import '../theme/app_colors.dart';
import 'session_page.dart';

class TemplateDetailPage extends StatefulWidget {
  final Template template;

  const TemplateDetailPage({super.key, required this.template});

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  List<_TemplateExercise> _exercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final locator = ServiceLocator.of(context);
    final templateId = widget.template.id;
    if (templateId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final items =
        await locator.templateRepository.getItemsForTemplate(templateId);
    final rows = <_TemplateExercise>[];
    for (final item in items) {
      final exercise =
          await locator.exerciseRepository.getById(item.exerciseId);
      if (exercise != null) {
        rows.add(_TemplateExercise(item: item, exercise: exercise));
      }
    }

    if (mounted) {
      setState(() {
        _exercises = rows;
        _loading = false;
      });
    }
  }

  Future<void> _startWorkout() async {
    final workout =
        await ServiceLocator.of(context).workoutService.startWorkout();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SessionPage(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templateDetail)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Text(
                  widget.template.localizedName(locale),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.templateExerciseCount(_exercises.length),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ..._exercises.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TemplateExerciseTile(row: row, locale: locale),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _startWorkout,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.useThisTemplate),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateExercise {
  final TemplateItem item;
  final Exercise exercise;

  const _TemplateExercise({required this.item, required this.exercise});
}

class _TemplateExerciseTile extends StatelessWidget {
  final _TemplateExercise row;
  final String locale;

  const _TemplateExerciseTile({required this.row, required this.locale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = row.exercise;
    final color = AppColors.forMuscleGroup(exercise.muscleGroup);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.localizedName(locale),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.defaultSetsReps(
                    row.item.defaultSets,
                    row.item.defaultReps,
                  ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
