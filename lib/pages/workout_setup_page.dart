import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/service_locator.dart';
import '../models/exercise.dart';
import '../models/workout_setup.dart';
import '../models/workout_set.dart';
import '../theme/app_colors.dart';
import '../widgets/anatomy_muscle_map.dart';
import '../widgets/exercise_demo.dart';
import '../widgets/muscle_group_chips.dart';

class WorkoutSetupPage extends StatefulWidget {
  const WorkoutSetupPage({super.key});

  @override
  State<WorkoutSetupPage> createState() => _WorkoutSetupPageState();
}

class _WorkoutSetupPageState extends State<WorkoutSetupPage> {
  TrainingGoal _goal = TrainingGoal.hypertrophy;
  String? _selectedMuscleGroup;
  Exercise? _selectedExercise;
  List<Exercise> _recentExercises = [];
  List<Exercise> _allExercises = [];
  bool _loadingExercises = false;
  double _recommendedWeight = 20;
  int _recommendedReps = 10;
  String _recommendationReason = '根据目标给出起始建议';

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _goal = TrainingGoalText.fromStorage(prefs.getString('training_goal'));
      _recommendedReps = _targetRepsForGoal(_goal);
    });
  }

  Future<void> _setGoal(TrainingGoal goal) async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_goal', goal.storageKey);
    if (!mounted) return;
    setState(() => _goal = goal);
    await _refreshRecommendation();
  }

  Future<void> _selectMuscleGroup(String group) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMuscleGroup = group;
      _selectedExercise = null;
      _allExercises = [];
      _recentExercises = [];
      _loadingExercises = true;
      _recommendedWeight = _defaultWeightForGroup(group);
      _recommendedReps = _targetRepsForGoal(_goal);
      _recommendationReason = '先按你的目标和肌群给一个保守起点';
    });

    final svc = ServiceLocator.of(context).exerciseService;
    final recent = await svc.getRecentlyUsed(group);
    final all = await svc.getByMuscleGroup(group);
    if (!mounted) return;
    setState(() {
      _recentExercises = recent;
      _allExercises = all;
      _loadingExercises = false;
    });
  }

  Future<void> _selectExercise(Exercise exercise) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedExercise = exercise);
    await _refreshRecommendation();
  }

  Future<void> _refreshRecommendation() async {
    final group = _selectedMuscleGroup;
    final exercise = _selectedExercise;
    if (group == null || exercise == null || exercise.id == null) {
      if (!mounted) return;
      setState(() {
        _recommendedWeight = _defaultWeightForGroup(group);
        _recommendedReps = _targetRepsForGoal(_goal);
        _recommendationReason = '先按你的目标和肌群给一个保守起点';
      });
      return;
    }

    final svc = ServiceLocator.of(context).workoutService;
    final lastSets = await svc.getLastSetsForExercise(exercise.id!);
    final recommendation = _buildRecommendation(group, lastSets);
    if (!mounted) return;
    setState(() {
      _recommendedWeight = recommendation.weight;
      _recommendedReps = recommendation.reps;
      _recommendationReason = recommendation.reason;
    });
  }

  _Recommendation _buildRecommendation(String group, List<WorkoutSet> history) {
    final targetReps = _targetRepsForGoal(_goal);
    if (history.isEmpty) {
      return _Recommendation(
        weight: _defaultWeightForGroup(group),
        reps: targetReps,
        reason: '暂无历史记录，按${_goal.label('zh')}目标推荐起始组',
      );
    }

    final last = history.first;
    var weight = last.weight;
    var reps = targetReps;
    var reason = '参考上次 ${_formatWeight(last.weight)}kg × ${last.reps}';

    switch (_goal) {
      case TrainingGoal.strength:
        reps = 5;
        if (last.reps >= 7) {
          weight += 2.5;
          reason = '$reason，完成次数充足，本次小幅加重';
        } else {
          reason = '$reason，本次先稳住重量';
        }
        break;
      case TrainingGoal.hypertrophy:
        reps = last.reps.clamp(8, 12);
        if (last.reps >= 12) {
          weight += 2.5;
          reps = 10;
          reason = '$reason，上次容量足够，本次加一点重量';
        } else {
          reason = '$reason，本次维持中等次数';
        }
        break;
      case TrainingGoal.endurance:
        reps = last.reps < 15 ? 15 : last.reps.clamp(15, 20);
        weight = last.weight * 0.9;
        reason = '$reason，耐力目标下调重量、提高次数';
        break;
    }

    return _Recommendation(
      weight: _roundToIncrement(weight),
      reps: reps,
      reason: reason,
    );
  }

  Future<void> _createCustomExercise() async {
    final group = _selectedMuscleGroup;
    if (group == null) return;

    final zhController = TextEditingController();
    final enController = TextEditingController();
    final created = await showDialog<Exercise>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('创建自定义动作'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: zhController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '动作名称'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: enController,
                decoration: const InputDecoration(labelText: '英文名（可选）'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = zhController.text.trim();
                if (name.isEmpty) return;
                final service = ServiceLocator.of(context).exerciseService;
                final exercise = await service.addCustomExercise(
                  nameZh: name,
                  nameEn: enController.text.trim().isEmpty
                      ? name
                      : enController.text.trim(),
                  muscleGroup: group,
                );
                if (ctx.mounted) Navigator.pop(ctx, exercise);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    zhController.dispose();
    enController.dispose();
    if (created == null || !mounted) return;

    await _selectMuscleGroup(group);
    await _selectExercise(created);
  }

  void _startWorkout() {
    final group = _selectedMuscleGroup;
    final exercise = _selectedExercise;
    if (group == null || exercise == null) return;
    Navigator.pop(
      context,
      WorkoutSetup(
        muscleGroup: group,
        exercise: exercise,
        goal: _goal,
        recommendedWeight: _recommendedWeight,
        recommendedReps: _recommendedReps,
        recommendationReason: _recommendationReason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final canStart = _selectedMuscleGroup != null && _selectedExercise != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('配置训练'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: canStart ? _startWorkout : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              '开始训练',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
                  AppColors.textHint.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SectionTitle(step: '1', title: '选择目标和肌群'),
          const SizedBox(height: 10),
          _GoalSelector(
            selected: _goal,
            locale: locale,
            onSelected: _setGoal,
          ),
          const SizedBox(height: 14),
          _MuscleMapCard(
            selectedMuscleGroup: _selectedMuscleGroup,
            onSelected: _selectMuscleGroup,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kMuscleGroups.map((group) {
              final selected = group == _selectedMuscleGroup;
              final color = AppColors.forMuscleGroup(group);
              return ChoiceChip(
                label: Text(muscleGroupLabel(context, group)),
                selected: selected,
                onSelected: (_) => _selectMuscleGroup(group),
                selectedColor: color,
                backgroundColor: color.withValues(alpha: 0.08),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: color.withValues(alpha: 0.3)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(step: '2', title: '选择动作'),
          const SizedBox(height: 10),
          if (_selectedMuscleGroup == null)
            const _EmptyStepHint(text: '先在上方选择一个肌群，再进入动作选择。')
          else if (_loadingExercises)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _ExerciseSelection(
              allExercises: _allExercises,
              recentExercises: _recentExercises,
              selectedExercise: _selectedExercise,
              locale: locale,
              onSelected: _selectExercise,
              onCreateCustom: _createCustomExercise,
            ),
          const SizedBox(height: 16),
          _RecommendationCard(
            weight: _recommendedWeight,
            reps: _recommendedReps,
            reason: _recommendationReason,
            enabled: canStart,
          ),
        ],
      ),
    );
  }

  int _targetRepsForGoal(TrainingGoal goal) => switch (goal) {
        TrainingGoal.strength => 5,
        TrainingGoal.hypertrophy => 10,
        TrainingGoal.endurance => 15,
      };

  double _defaultWeightForGroup(String? group) => switch (group) {
        'legs' => 40,
        'chest' => 30,
        'back' => 30,
        'shoulders' => 15,
        'arms' => 10,
        'core' => 0,
        'full_body' => 20,
        _ => 20,
      };

  double _roundToIncrement(double value) => (value / 1.25).round() * 1.25;

  String _formatWeight(double value) => value == value.truncate()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

class _Recommendation {
  final double weight;
  final int reps;
  final String reason;

  const _Recommendation({
    required this.weight,
    required this.reps,
    required this.reason,
  });
}

class _SectionTitle extends StatelessWidget {
  final String step;
  final String title;

  const _SectionTitle({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final TrainingGoal selected;
  final String locale;
  final ValueChanged<TrainingGoal> onSelected;

  const _GoalSelector({
    required this.selected,
    required this.locale,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TrainingGoal>(
      segments: TrainingGoal.values
          .map(
            (goal) => ButtonSegment(
              value: goal,
              label: Text(goal.label(locale)),
              tooltip: goal.repHint(locale),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (values) => onSelected(values.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _MuscleMapCard extends StatelessWidget {
  final String? selectedMuscleGroup;
  final ValueChanged<String> onSelected;

  const _MuscleMapCard({
    required this.selectedMuscleGroup,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLabel = selectedMuscleGroup == null
        ? '点击图示选择肌群'
        : muscleGroupLabel(context, selectedMuscleGroup!);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnatomyMuscleMap(
                  selectedGroup: selectedMuscleGroup,
                  onSelected: onSelected,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '人体肌群',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedLabel,
                  style: TextStyle(
                    color: selectedMuscleGroup == null
                        ? AppColors.textHint
                        : AppColors.forMuscleGroup(selectedMuscleGroup!),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '先确定训练部位，下一步只显示相关动作。',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
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

class _ExerciseSelection extends StatelessWidget {
  final List<Exercise> allExercises;
  final List<Exercise> recentExercises;
  final Exercise? selectedExercise;
  final String locale;
  final ValueChanged<Exercise> onSelected;
  final VoidCallback onCreateCustom;

  const _ExerciseSelection({
    required this.allExercises,
    required this.recentExercises,
    required this.selectedExercise,
    required this.locale,
    required this.onSelected,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
    final recentIds = recentExercises.map((e) => e.id).whereType<int>().toSet();
    final ordered = [
      ...recentExercises,
      ...allExercises.where((e) => e.id == null || !recentIds.contains(e.id)),
    ];

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '动作演示在卡片内循环播放，点卡片只会选中动作。',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: onCreateCustom,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('自定义'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...ordered.map((exercise) {
          final selected = exercise.id == selectedExercise?.id;
          final isRecent = recentIds.contains(exercise.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExerciseCard(
              exercise: exercise,
              locale: locale,
              selected: selected,
              isRecent: isRecent,
              onTap: () => onSelected(exercise),
            ),
          );
        }),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String locale;
  final bool selected;
  final bool isRecent;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.locale,
    required this.selected,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forMuscleGroup(exercise.muscleGroup);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected ? color : AppColors.textHint.withValues(alpha: 0.18),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ExerciseDemoLoop(muscleGroup: exercise.muscleGroup, size: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.localizedName(locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (locale.startsWith('zh') && exercise.nameEn.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        exercise.nameEn,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (isRecent) const _MiniBadge(label: '最近练过'),
                      if (exercise.isCustom) const _MiniBadge(label: '自定义'),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? color : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final double weight;
  final int reps;
  final String reason;
  final bool enabled;

  const _RecommendationCard({
    required this.weight,
    required this.reps,
    required this.reason,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final weightText = weight == weight.truncate()
        ? weight.toInt().toString()
        : weight.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.accent.withValues(alpha: 0.09)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? AppColors.accent.withValues(alpha: 0.32)
              : AppColors.textHint.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: enabled ? AppColors.accent : AppColors.textHint,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? '推荐起始组：$weightText kg × $reps' : '选好动作后生成推荐',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
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

class _EmptyStepHint extends StatelessWidget {
  final String text;

  const _EmptyStepHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
