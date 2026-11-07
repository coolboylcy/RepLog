import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_provider.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../models/template_item.dart';
import '../widgets/set_input_panel.dart';
import '../widgets/exercise_picker.dart';

class SessionPage extends StatefulWidget {
  final int workoutId;
  final List<TemplateItem>? templateItems;

  const SessionPage({
    super.key,
    required this.workoutId,
    this.templateItems,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final Stopwatch _stopwatch = Stopwatch();
  List<WorkoutSet> _sets = [];
  Exercise? _currentExercise;
  bool _isKg = true;
  int _templateIndex = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isKg = prefs.getString('weight_unit') != 'lb';
    if (widget.templateItems != null && widget.templateItems!.isNotEmpty) {
      await _loadFirstTemplateExercise();
    }
  }

  Future<void> _loadFirstTemplateExercise() async {
    if (widget.templateItems == null || widget.templateItems!.isEmpty) return;
    final sp = ServiceProvider.of(context);
    final item = widget.templateItems![0];
    final exercise = await sp.exerciseService.getExerciseById(item.exerciseId);
    if (exercise != null && mounted) {
      setState(() {
        _currentExercise = exercise;
        _templateIndex = 0;
      });
    }
  }

  Future<void> _loadNextTemplateExercise() async {
    if (widget.templateItems == null) return;
    _templateIndex++;
    if (_templateIndex >= widget.templateItems!.length) return;

    final sp = ServiceProvider.of(context);
    final item = widget.templateItems![_templateIndex];
    final exercise = await sp.exerciseService.getExerciseById(item.exerciseId);
    if (exercise != null && mounted) {
      setState(() => _currentExercise = exercise);
    }
  }

  Future<void> _loadSets() async {
    final sp = ServiceProvider.of(context);
    final sets = await sp.workoutService.getSetsForWorkout(widget.workoutId);
    if (mounted) setState(() => _sets = sets);
  }

  Future<void> _addSet(double weight, int reps) async {
    if (_currentExercise == null) return;
    final sp = ServiceProvider.of(context);

    final setNumber = _sets
            .where((s) => s.exerciseId == _currentExercise!.id)
            .length +
        1;

    await sp.workoutService.addSet(
      workoutId: widget.workoutId,
      exerciseId: _currentExercise!.id!,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
    );

    await _checkPR(weight, reps);
    await _loadSets();

    if (widget.templateItems != null) {
      final templateItem = _templateIndex < widget.templateItems!.length
          ? widget.templateItems![_templateIndex]
          : null;
      if (templateItem != null && setNumber >= templateItem.defaultSets) {
        _loadNextTemplateExercise();
      }
    }
  }

  Future<void> _checkPR(double weight, int reps) async {
    if (_currentExercise == null) return;
    final sp = ServiceProvider.of(context);
    final pr = await sp.statsRepository.getExercisePR(_currentExercise!.id!);
    if (pr == null) return;

    final isWeightPR = weight > (pr['max_weight'] as double);
    final isVolumePR = weight * reps > (pr['max_volume'] as double);

    if (isWeightPR || isVolumePR) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.newPR),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePicker(
        onSelected: (exercise) {
          setState(() => _currentExercise = exercise);
        },
      ),
    );
  }

  Future<void> _finishWorkout() async {
    _stopwatch.stop();
    final sp = ServiceProvider.of(context);
    await sp.workoutService.finishWorkout(
      widget.workoutId,
      _stopwatch.elapsed.inMinutes,
    );
    if (mounted) Navigator.pop(context);
  }

  WorkoutSet? get _lastSetForCurrentExercise {
    if (_currentExercise == null) return null;
    final exerciseSets =
        _sets.where((s) => s.exerciseId == _currentExercise!.id).toList();
    return exerciseSets.isNotEmpty ? exerciseSets.last : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final exerciseGroups = <int, List<WorkoutSet>>{};
    for (final s in _sets) {
      exerciseGroups.putIfAbsent(s.exerciseId, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (_, __) {
            final elapsed = _stopwatch.elapsed;
            return Text(
              '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
            );
          },
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: Text(l10n.finishWorkout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _sets.isEmpty
                ? Center(
                    child: Text(
                      '选择一个动作开始训练',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: exerciseGroups.entries.map((entry) {
                      final sets = entry.value;
                      final name = sets.first.exerciseNameZh ?? '';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...sets.map((s) {
                                final unit = _isKg ? 'kg' : 'lb';
                                final w = _isKg
                                    ? s.weight
                                    : s.weight * 2.20462;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          '${s.setNumber}',
                                          style:
                                              theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                      Text(
                                          '${w.toStringAsFixed(1)} $unit × ${s.reps}'),
                                      const Spacer(),
                                      Text(
                                        '${s.volume.toStringAsFixed(0)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          if (_currentExercise != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentExercise!.nameZh,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: _showExercisePicker,
                        child: const Text('切换'),
                      ),
                    ],
                  ),
                  SetInputPanel(
                    lastSet: _lastSetForCurrentExercise,
                    isKg: _isKg,
                    onAdd: (data) => _addSet(data.weight, data.reps),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonalIcon(
                onPressed: _showExercisePicker,
                icon: const Icon(Icons.add),
                label: Text(l10n.addExercise),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSets();
  }
}
