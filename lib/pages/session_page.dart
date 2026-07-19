import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/service_locator.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../models/exercise.dart';
import '../models/workout_setup.dart';
import '../theme/app_colors.dart';
import '../widgets/set_input_panel.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/session_set_list.dart';
import '../widgets/exercise_demo.dart';
import '../widgets/muscle_group_chips.dart';

class SessionPage extends StatefulWidget {
  final Workout workout;
  final WorkoutSetup? initialSetup;

  const SessionPage({
    super.key,
    required this.workout,
    this.initialSetup,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with WidgetsBindingObserver {
  late Workout _workout;
  String? _selectedMuscleGroup;
  Exercise? _selectedExercise;
  List<WorkoutSet> _sets = [];
  WorkoutSet? _lastSet; // 上次该动作的记录

  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  final _restTimerKey = GlobalKey<RestTimerWidgetState>();
  final _inputPanelKey = GlobalKey<SetInputPanelState>();

  bool _isKg = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _workout = widget.workout;
    final setup = widget.initialSetup;
    if (setup != null) {
      _selectedMuscleGroup = setup.muscleGroup;
      _selectedExercise = setup.exercise;
    }
    _startElapsedTimer();
    _loadSets();
    _loadWeightUnit();
    _loadInitialLastSet();
  }

  Future<void> _loadInitialLastSet() async {
    final setup = widget.initialSetup;
    if (setup?.exercise.id == null) return;
    final workoutSvc = ServiceLocator.of(context).workoutService;
    final lastSets =
        await workoutSvc.getLastSetsForExercise(setup!.exercise.id!);
    if (!mounted) return;
    setState(() => _lastSet = lastSets.isNotEmpty ? lastSets.first : null);
  }

  Future<void> _loadWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isKg = prefs.getString('weight_unit') != 'lb');
  }

  void _startElapsedTimer() {
    final start = DateTime.parse(_workout.startedAt);
    _elapsedSeconds = DateTime.now().difference(start).inSeconds;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final start = DateTime.parse(_workout.startedAt);
      setState(() {
        _elapsedSeconds = DateTime.now().difference(start).inSeconds;
      });
    }
  }

  Future<void> _loadSets() async {
    final svc = ServiceLocator.of(context).workoutService;
    final sets = await svc.getSetsForWorkout(_workout.id!);
    setState(() => _sets = sets);
  }

  Future<void> _logSet() async {
    if (_selectedExercise == null) {
      _showSnack(AppLocalizations.of(context)!.selectExercise);
      return;
    }

    final panelState = _inputPanelKey.currentState;
    if (panelState == null) return;

    HapticFeedback.mediumImpact();

    final svc = ServiceLocator.of(context).workoutService;
    final saved = await svc.logSet(
      workoutId: _workout.id!,
      exerciseId: _selectedExercise!.id!,
      exerciseName: _selectedExercise!
          .localizedName(Localizations.localeOf(context).languageCode),
      muscleGroup: _selectedMuscleGroup!,
      weight: panelState.weight,
      reps: panelState.reps,
    );

    setState(() {
      _sets.add(saved);
      _lastSet = saved;
    });

    // 启动休息计时器
    _restTimerKey.currentState?.start();

    if (mounted) {
      _showSnack(AppLocalizations.of(context)!.setLogged);
    }
  }

  Future<void> _deleteSet(WorkoutSet set) async {
    final svc = ServiceLocator.of(context).workoutService;
    await svc.deleteSet(set);
    setState(() => _sets.removeWhere((s) => s.id == set.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.setDeleted),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.undo,
            onPressed: () async {
              final workoutSvc = ServiceLocator.of(context).workoutService;
              final re = await workoutSvc.logSet(
                workoutId: set.workoutId,
                exerciseId: set.exerciseId,
                exerciseName: set.exerciseName,
                muscleGroup: set.muscleGroup,
                weight: set.weight,
                reps: set.reps,
              );
              setState(() => _sets.add(re));
            },
          ),
        ),
      );
    }
  }

  Future<void> _endWorkout() async {
    final l10n = AppLocalizations.of(context)!;
    final isEmpty = _sets.isEmpty;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.endWorkout),
        content: Text(
            isEmpty ? l10n.endWorkoutConfirmEmpty : l10n.endWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEmpty ? AppColors.error : null,
            ),
            child: Text(isEmpty ? l10n.discard : l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    final svc = ServiceLocator.of(context).workoutService;
    if (isEmpty) {
      await svc.discardWorkout(_workout.id!);
    } else {
      await svc.endWorkout(_workout.id!);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(message), duration: const Duration(seconds: 1)));
  }

  String get _elapsedLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endWorkout();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── 顶部栏 ────────────────────────────
              _TopBar(
                elapsedLabel: _elapsedLabel,
                setCount: _sets.length,
                onEnd: _endWorkout,
              ),

              // ── 当前动作 ──────────────────────────
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CurrentExerciseCard(
                  exercise: _selectedExercise,
                  muscleGroup: _selectedMuscleGroup,
                ),
              ),

              // ── 已记录组数 ────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: SessionSetList(
                    sets: _sets,
                    isKg: _isKg,
                    onDelete: _deleteSet,
                  ),
                ),
              ),

              // ── 休息计时器 ────────────────────────
              RestTimerWidget(key: _restTimerKey),

              // ── 组数输入面板 ──────────────────────
              SetInputPanel(
                key: _inputPanelKey,
                lastSet: _lastSet,
                initialWeight: widget.initialSetup?.recommendedWeight,
                initialReps: widget.initialSetup?.recommendedReps,
                recommendationLabel: widget.initialSetup?.recommendationReason,
                isKg: _isKg,
                onLogSet: _logSet,
                onValuesChanged: (_, __) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String elapsedLabel;
  final int setCount;
  final VoidCallback onEnd;

  const _TopBar({
    required this.elapsedLabel,
    required this.setCount,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: AppColors.surface,
      child: Row(
        children: [
          // 计时器
          const Icon(Icons.timer_outlined,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            elapsedLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 16),
          // 组数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.workoutSets(setCount),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          // 结束按钮
          TextButton(
            onPressed: onEnd,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.08),
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.endWorkout,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _CurrentExerciseCard extends StatelessWidget {
  final Exercise? exercise;
  final String? muscleGroup;

  const _CurrentExerciseCard({
    required this.exercise,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final group = muscleGroup ?? exercise?.muscleGroup;
    final color =
        group == null ? AppColors.textHint : AppColors.forMuscleGroup(group);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          if (group != null)
            ExerciseDemoLoop(muscleGroup: group, size: 64)
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.fitness_center, color: AppColors.textHint),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前动作',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise?.localizedName(locale) ?? '未配置动作',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (group != null)
                  MuscleGroupTag(muscleGroup: group)
                else
                  const Text(
                    '请从首页重新开始并完成训练配置',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }
}
