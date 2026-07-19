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
  List<Exercise> _allExercises = [];
  List<Exercise> _recentExercises = [];
  List<PlannedExercise> _plan = [];
  bool _loadingPlan = false;

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
    });
  }

  Future<void> _setGoal(TrainingGoal goal) async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_goal', goal.storageKey);
    if (!mounted) return;
    setState(() => _goal = goal);
    await _generatePlan();
  }

  Future<void> _selectMuscleGroup(String group) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMuscleGroup = group;
      _loadingPlan = true;
      _plan = [];
    });
    await _loadExercises(group);
    await _generatePlan();
  }

  Future<void> _loadExercises(String group) async {
    final svc = ServiceLocator.of(context).exerciseService;
    final recent = await svc.getRecentlyUsed(group);
    final all = await svc.getByMuscleGroup(group);
    if (!mounted) return;
    setState(() {
      _recentExercises = recent;
      _allExercises = all;
    });
  }

  Future<void> _generatePlan() async {
    final group = _selectedMuscleGroup;
    if (group == null) return;

    setState(() => _loadingPlan = true);
    if (_allExercises.isEmpty) {
      await _loadExercises(group);
    }

    final recentIds =
        _recentExercises.map((e) => e.id).whereType<int>().toSet();
    final ordered = [
      ..._recentExercises,
      ..._allExercises.where((e) => e.id == null || !recentIds.contains(e.id)),
    ];
    final targetCount = group == 'core' || group == 'full_body' ? 3 : 4;
    final selected = ordered.take(targetCount).toList();
    final built = <PlannedExercise>[];
    for (var i = 0; i < selected.length; i++) {
      built.add(await _buildPlannedExercise(selected[i], index: i));
    }

    if (!mounted) return;
    setState(() {
      _plan = built;
      _loadingPlan = false;
    });
  }

  Future<PlannedExercise> _buildPlannedExercise(
    Exercise exercise, {
    required int index,
  }) async {
    final group = _selectedMuscleGroup ?? exercise.muscleGroup;
    final svc = ServiceLocator.of(context).workoutService;
    final history = exercise.id == null
        ? <WorkoutSet>[]
        : await svc.getLastSetsForExercise(exercise.id!);
    final recommendation = _buildRecommendation(group, history);
    return PlannedExercise(
      muscleGroup: group,
      exercise: exercise,
      goal: _goal,
      recommendedWeight: recommendation.weight,
      targetReps: recommendation.reps,
      targetSets: _targetSetsForGoal(_goal, index),
      recommendationReason: recommendation.reason,
    );
  }

  _Recommendation _buildRecommendation(String group, List<WorkoutSet> history) {
    final targetReps = _targetRepsForGoal(_goal);
    if (history.isEmpty) {
      return _Recommendation(
        weight: _defaultWeightForGroup(group),
        reps: targetReps,
        reason: '暂无历史记录，按${_goal.label('zh')}目标给保守起点',
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
        }
        break;
      case TrainingGoal.hypertrophy:
        reps = last.reps.clamp(8, 12);
        if (last.reps >= 12) {
          weight += 2.5;
          reps = 10;
          reason = '$reason，上次容量足够，本次加一点重量';
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

  void _removePlanItem(PlannedExercise item) {
    HapticFeedback.selectionClick();
    setState(() => _plan.remove(item));
  }

  void _changeTargetSets(PlannedExercise item, int delta) {
    final next = (item.targetSets + delta).clamp(1, 8);
    setState(() {
      final index = _plan.indexOf(item);
      if (index >= 0) _plan[index] = item.copyWith(targetSets: next);
    });
  }

  Future<void> _addExercise() async {
    final group = _selectedMuscleGroup;
    if (group == null) return;

    final usedIds = _plan.map((e) => e.exercise.id).whereType<int>().toSet();
    final candidates = _allExercises
        .where(
            (exercise) => exercise.id == null || !usedIds.contains(exercise.id))
        .toList();
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddExerciseSheet(
        exercises: candidates,
        muscleGroup: group,
        onCreateCustom: () async {
          final created = await _createCustomExercise();
          if (ctx.mounted && created != null) Navigator.pop(ctx, created);
        },
      ),
    );
    if (selected == null || !mounted) return;
    final item = await _buildPlannedExercise(selected, index: _plan.length);
    if (!mounted) return;
    setState(() => _plan.add(item));
  }

  Future<Exercise?> _createCustomExercise() async {
    final group = _selectedMuscleGroup;
    if (group == null) return null;

    final zhController = TextEditingController();
    final enController = TextEditingController();
    final created = await showDialog<Exercise>(
      context: context,
      builder: (ctx) => AlertDialog(
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
      ),
    );

    zhController.dispose();
    enController.dispose();
    if (created != null) {
      await _loadExercises(group);
    }
    return created;
  }

  void _startWorkout() {
    final group = _selectedMuscleGroup;
    if (group == null || _plan.isEmpty) return;
    Navigator.pop(
      context,
      WorkoutSetup(
        goal: _goal,
        primaryMuscleGroup: group,
        exercises: List.unmodifiable(_plan),
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final canStart = _selectedMuscleGroup != null && _plan.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('今日训练计划'),
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
            label: Text(
              canStart ? '按计划开始训练' : '先生成今日计划',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
          const _SectionTitle(step: '1', title: '选择今日目标和部位'),
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
          Row(
            children: [
              const Expanded(child: _SectionTitle(step: '2', title: '本日计划')),
              if (_selectedMuscleGroup != null)
                TextButton.icon(
                  onPressed: _generatePlan,
                  icon: const Icon(Icons.auto_awesome, size: 17),
                  label: const Text('重新生成'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedMuscleGroup == null)
            const _EmptyStepHint(text: '先选今日训练部位，系统会自动设计动作、重量、次数和组数。')
          else if (_loadingPlan)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (_plan.isEmpty)
              const _EmptyStepHint(text: '当前计划为空，可以添加动作或重新生成。')
            else
              ..._plan.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlanExerciseCard(
                    item: item,
                    locale: locale,
                    onRemove: () => _removePlanItem(item),
                    onDecreaseSets: () => _changeTargetSets(item, -1),
                    onIncreaseSets: () => _changeTargetSets(item, 1),
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('添加动作'),
            ),
          ],
        ],
      ),
    );
  }

  int _targetRepsForGoal(TrainingGoal goal) => switch (goal) {
        TrainingGoal.strength => 5,
        TrainingGoal.hypertrophy => 10,
        TrainingGoal.endurance => 15,
      };

  int _targetSetsForGoal(TrainingGoal goal, int index) => switch (goal) {
        TrainingGoal.strength => index == 0 ? 5 : 3,
        TrainingGoal.hypertrophy => index == 0 ? 4 : 3,
        TrainingGoal.endurance => 3,
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
        ? '点击图示选择部位'
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
                  '今日部位',
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
                  '选择后会自动生成今日动作、重量建议、次数和组数。',
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

class _PlanExerciseCard extends StatelessWidget {
  final PlannedExercise item;
  final String locale;
  final VoidCallback onRemove;
  final VoidCallback onDecreaseSets;
  final VoidCallback onIncreaseSets;

  const _PlanExerciseCard({
    required this.item,
    required this.locale,
    required this.onRemove,
    required this.onDecreaseSets,
    required this.onIncreaseSets,
  });

  @override
  Widget build(BuildContext context) {
    final weight = item.recommendedWeight == item.recommendedWeight.truncate()
        ? item.recommendedWeight.toInt().toString()
        : item.recommendedWeight.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.forMuscleGroup(item.muscleGroup)
              .withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          ExerciseDemoLoop(muscleGroup: item.muscleGroup, size: 70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.exercise.localizedName(locale),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$weight kg · ${item.targetSets} 组 × ${item.targetReps} 次',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.recommendationReason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TinyIconButton(icon: Icons.remove, onTap: onDecreaseSets),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.targetSets} 组',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _TinyIconButton(icon: Icons.add, onTap: onIncreaseSets),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TinyIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _AddExerciseSheet extends StatelessWidget {
  final List<Exercise> exercises;
  final String muscleGroup;
  final VoidCallback onCreateCustom;

  const _AddExerciseSheet({
    required this.exercises,
    required this.muscleGroup,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '添加计划动作',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onCreateCustom,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('自定义'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    leading: ExerciseDemoLoop(
                      muscleGroup: muscleGroup,
                      size: 54,
                    ),
                    title: Text(
                      exercise.localizedName(locale),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle:
                        locale.startsWith('zh') && exercise.nameEn.isNotEmpty
                            ? Text(exercise.nameEn)
                            : null,
                    onTap: () => Navigator.pop(context, exercise),
                  );
                },
              ),
            ),
          ],
        );
      },
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
