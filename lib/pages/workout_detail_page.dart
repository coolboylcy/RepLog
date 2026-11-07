import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_provider.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import 'exercise_history_page.dart';

class WorkoutDetailPage extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  Workout? _workout;
  List<WorkoutSet> _sets = [];
  bool _isKg = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final prefs = await SharedPreferences.getInstance();
    final workout = await sp.workoutService.getWorkoutById(widget.workoutId);
    final sets = await sp.workoutService.getSetsForWorkout(widget.workoutId);
    final isKg = prefs.getString('weight_unit') != 'lb';
    if (mounted) {
      setState(() {
        _workout = workout;
        _sets = sets;
        _isKg = isKg;
      });
    }
  }

  Future<void> _deleteWorkout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteWorkout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final sp = ServiceProvider.of(context);
      await sp.workoutService.deleteWorkout(widget.workoutId);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unit = _isKg ? 'kg' : 'lb';

    if (_workout == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final exerciseGroups = <int, List<WorkoutSet>>{};
    for (final s in _sets) {
      exerciseGroups.putIfAbsent(s.exerciseId, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_workout!.templateName ?? '自由训练'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteWorkout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(_workout!.date,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('日期', style: theme.textTheme.labelSmall),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${_workout!.totalSets}',
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(l10n.sets, style: theme.textTheme.labelSmall),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${_workout!.durationMinutes}',
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(l10n.minutes, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...exerciseGroups.entries.map((entry) {
            final sets = entry.value;
            final nameZh = sets.first.exerciseNameZh ?? '';
            final exerciseId = sets.first.exerciseId;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseHistoryPage(
                              exerciseId: exerciseId,
                              exerciseName: nameZh,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        nameZh,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sets.map((s) {
                      final w =
                          _isKg ? s.weight : s.weight * 2.20462;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text('${s.setNumber}',
                                  style: theme.textTheme.bodyMedium),
                            ),
                            Text('${w.toStringAsFixed(1)} $unit × ${s.reps}'),
                            const Spacer(),
                            Text('${s.volume.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
