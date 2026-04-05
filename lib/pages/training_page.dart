import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../models/workout.dart';
import '../theme/app_colors.dart';
import '../widgets/workout_card.dart';
import 'session_page.dart';
import 'workout_detail_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with AutomaticKeepAliveClientMixin {
  Workout? _activeWorkout;
  List<Workout> _recentWorkouts = [];
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
    final recent = await svc.getRecentWorkouts(limit: 3);
    if (mounted) {
      setState(() {
        _activeWorkout = active;
        _recentWorkouts = recent;
        _loading = false;
      });
    }
  }

  Future<void> _startWorkout() async {
    final svc = ServiceLocator.of(context).workoutService;
    final workout = await svc.startWorkout();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SessionPage(workout: workout),
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
                    SliverAppBar(
                      floating: true,
                      title: const Text(
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
                          _SplitGuidanceSection(),

                          // ── 最近训练 ────────────────
                          if (_recentWorkouts.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(l10n.recentWorkouts,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ..._recentWorkouts.map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: WorkoutCard(
                                  workout: w,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          WorkoutDetailPage(workout: w),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 32),
                            Center(
                              child: Text(
                                l10n.noWorkoutsYet,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  height: 1.6,
                                ),
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

class _ActiveWorkoutBanner extends StatelessWidget {
  final Workout workout;
  final VoidCallback onContinue;

  const _ActiveWorkoutBanner(
      {required this.workout, required this.onContinue});

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
        gradient: LinearGradient(
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
                        color: Colors.white.withOpacity(0.8), fontSize: 12)),
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

  const _StartWorkoutButton(
      {required this.hasActive, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onStart,
        icon: Icon(hasActive ? Icons.play_arrow : Icons.add,
            size: 22),
        label: Text(
          hasActive ? l10n.continueWorkout : l10n.startWorkout,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasActive ? AppColors.accent : AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
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
        color: data.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withOpacity(0.2)),
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
                        color: data.color.withOpacity(0.12),
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
