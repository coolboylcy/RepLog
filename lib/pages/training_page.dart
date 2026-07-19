import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../app/service_locator.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../theme/app_colors.dart';
import '../widgets/muscle_group_chips.dart';
import 'session_page.dart';
import 'workout_detail_page.dart';
import 'workout_setup_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with AutomaticKeepAliveClientMixin {
  Workout? _activeWorkout;
  List<_RecentWorkoutDetails> _recentWorkouts = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final svc = ServiceLocator.of(context).workoutService;
    final active = await svc.getActive();
    final recent = await svc.getRecentWorkouts(limit: 6);
    final details = <_RecentWorkoutDetails>[];
    for (final workout in recent) {
      final sets = await svc.getSetsForWorkout(workout.id!);
      details.add(_RecentWorkoutDetails(workout: workout, sets: sets));
    }
    if (mounted) {
      setState(() {
        _activeWorkout = active;
        _recentWorkouts = details;
        _loading = false;
      });
    }
  }

  Future<void> _startWorkout() async {
    final setup = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const WorkoutSetupPage(),
      ),
    );
    if (setup == null || !mounted) return;

    final svc = ServiceLocator.of(context).workoutService;
    final workout = await svc.startWorkout();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SessionPage(
          workout: workout,
          initialSetup: setup,
        ),
      ),
    );
    _loadData();
  }

  void _continueWorkout() {
    if (_activeWorkout == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SessionPage(workout: _activeWorkout!),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    // ── App Bar ─────────────────────
                    const SliverAppBar(
                      floating: true,
                      title: Text(
                        'RepLog',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      backgroundColor: AppColors.background,
                      surfaceTintColor: Colors.transparent,
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── 活跃训练横幅 ────────────
                          if (_activeWorkout != null) ...[
                            _ActiveWorkoutBanner(
                              workout: _activeWorkout!,
                              onContinue: _continueWorkout,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── 开始训练 CTA ────────────
                          _StartWorkoutButton(
                            hasActive: _activeWorkout != null,
                            onStart: _activeWorkout == null
                                ? _startWorkout
                                : _continueWorkout,
                          ),

                          // ── 分化训练指引 ────────────
                          const SizedBox(height: 24),
                          const _SplitGuidanceSection(),

                          // ── 最近训练 ────────────────
                          if (_recentWorkouts.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              l10n.recentWorkouts,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _RecentWorkoutsByDate(
                              workouts: _recentWorkouts,
                              onOpen: (w) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkoutDetailPage(workout: w),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.fitness_center,
                                      size: 48,
                                      color: AppColors.textHint
                                          .withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.noWorkoutsYet,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textHint,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RecentWorkoutDetails {
  final Workout workout;
  final List<WorkoutSet> sets;

  const _RecentWorkoutDetails({required this.workout, required this.sets});

  List<_ExerciseSummary> get exerciseSummaries {
    final grouped = <String, List<WorkoutSet>>{};
    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }
    return grouped.entries
        .map((entry) => _ExerciseSummary(name: entry.key, sets: entry.value))
        .toList();
  }
}

class _ExerciseSummary {
  final String name;
  final List<WorkoutSet> sets;

  const _ExerciseSummary({required this.name, required this.sets});

  String get muscleGroup => sets.isEmpty ? '' : sets.first.muscleGroup;
  double get volume => sets.fold(0, (sum, set) => sum + set.volume);
}

class _RecentWorkoutsByDate extends StatelessWidget {
  final List<_RecentWorkoutDetails> workouts;
  final ValueChanged<Workout> onOpen;

  const _RecentWorkoutsByDate({
    required this.workouts,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final grouped = <String, List<_RecentWorkoutDetails>>{};
    for (final details in workouts) {
      final started = DateTime.parse(details.workout.startedAt);
      final key = DateFormat(
        locale.startsWith('zh') ? 'MM月dd日 EEEE' : 'EEEE, MMM d',
        locale.startsWith('zh') ? 'zh_CN' : 'en_US',
      ).format(started);
      grouped.putIfAbsent(key, () => []).add(details);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ...entry.value.map(
                (details) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentWorkoutCard(
                    details: details,
                    onTap: () => onOpen(details.workout),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RecentWorkoutCard extends StatelessWidget {
  final _RecentWorkoutDetails details;
  final VoidCallback onTap;

  const _RecentWorkoutCard({
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final workout = details.workout;
    final start = DateTime.parse(workout.startedAt);
    final time = DateFormat('HH:mm').format(start);
    final duration = workout.durationSeconds == null
        ? null
        : '${workout.durationSeconds! ~/ 60}min';
    final summaries = details.exerciseSummaries;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (duration != null)
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${workout.totalSets} 组 · ${workout.totalVolume.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (summaries.isEmpty)
                const Text(
                  '没有记录动作',
                  style: TextStyle(color: AppColors.textHint),
                )
              else
                ...summaries
                    .map((summary) => _ExerciseSummaryRow(summary: summary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseSummaryRow extends StatelessWidget {
  final _ExerciseSummary summary;

  const _ExerciseSummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final sorted = [...summary.sets]..sort((a, b) =>
        DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
    final restLabels = <String>[];
    for (var i = 1; i < sorted.length; i++) {
      final previous = DateTime.parse(sorted[i - 1].createdAt);
      final current = DateTime.parse(sorted[i].createdAt);
      final seconds = current.difference(previous).inSeconds;
      if (seconds > 10) {
        restLabels.add(_formatRest(seconds));
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (summary.muscleGroup.isNotEmpty)
                MuscleGroupTag(muscleGroup: summary.muscleGroup),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.map((set) {
              final weight = set.weight == set.weight.truncate()
                  ? set.weight.toInt().toString()
                  : set.weight.toStringAsFixed(1);
              return _SetPill(text: '$weight kg × ${set.reps}');
            }).toList(),
          ),
          if (restLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '组间休息：${restLabels.join(' / ')}',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRest(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    if (minutes == 0) return '${rest}s';
    if (rest == 0) return '${minutes}min';
    return '${minutes}m ${rest}s';
  }
}

class _SetPill extends StatelessWidget {
  final String text;

  const _SetPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActiveWorkoutBanner extends StatelessWidget {
  final Workout workout;
  final VoidCallback onContinue;

  const _ActiveWorkoutBanner({required this.workout, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final start = DateTime.parse(workout.startedAt);
    final elapsed = DateTime.now().difference(start);
    final m = elapsed.inMinutes;
    final elapsedStr = m < 60 ? '${m}min' : '${m ~/ 60}h ${m % 60}min';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.workoutInProgress,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('$elapsedStr · ${l10n.workoutSets(workout.totalSets)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.continueWorkout,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  final bool hasActive;
  final VoidCallback onStart;

  const _StartWorkoutButton({required this.hasActive, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onStart,
        icon: Icon(hasActive ? Icons.play_arrow : Icons.add, size: 22),
        label: Text(
          hasActive ? l10n.continueWorkout : '制定今日计划',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasActive ? AppColors.accent : AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _SplitGuidanceSection extends StatelessWidget {
  const _SplitGuidanceSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final splits = [
      _SplitData(
        label: l10n.splitThreeDay,
        days: ['${l10n.push} (A)', '${l10n.pull} (B)', '${l10n.legs} (C)'],
        color: AppColors.primary,
        icon: Icons.repeat_one,
      ),
      _SplitData(
        label: l10n.splitFiveDay,
        days: [
          '${l10n.muscleChest}(A)',
          '${l10n.muscleBack}(B)',
          '${l10n.muscleShoulders}(C)',
          '${l10n.muscleLegs}(D)',
          '${l10n.muscleArms}(E)',
        ],
        color: AppColors.accent,
        icon: Icons.repeat,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.splitGuidance,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: splits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _SplitCard(data: splits[i]),
          ),
        ),
      ],
    );
  }
}

class _SplitData {
  final String label;
  final List<String> days;
  final Color color;
  final IconData icon;

  const _SplitData(
      {required this.label,
      required this.days,
      required this.color,
      required this.icon});
}

class _SplitCard extends StatelessWidget {
  final _SplitData data;

  const _SplitCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: data.color),
              const SizedBox(width: 6),
              Text(data.label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: data.color,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: data.days
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(d,
                          style: TextStyle(
                              fontSize: 10,
                              color: data.color,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
