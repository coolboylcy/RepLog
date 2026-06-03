import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../app/service_locator.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../theme/app_colors.dart';
import '../widgets/muscle_group_chips.dart';

class WorkoutDetailPage extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<WorkoutSet> _sets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ServiceLocator.of(context).workoutService;
    final sets = await svc.getSetsForWorkout(widget.workout.id!);
    setState(() {
      _sets = sets;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workout = widget.workout;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(workout.startedAt);
    final dateStr = DateFormat(
            locale.startsWith('zh') ? 'yyyy年MM月dd日' : 'MMMM d, yyyy',
            locale.startsWith('zh') ? 'zh_CN' : 'en_US')
        .format(date);

    // 按动作分组
    final grouped = <String, List<WorkoutSet>>{};
    for (final s in _sets) {
      grouped.putIfAbsent(s.exerciseName, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutDetail),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期
                  Text(dateStr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // 肌群标签
                  if (workout.muscleGroupList.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: workout.muscleGroupList
                          .map((g) => MuscleGroupTag(muscleGroup: g))
                          .toList(),
                    ),
                  const SizedBox(height: 12),

                  // 摘要
                  _SummaryRow(workout: workout),
                  const SizedBox(height: 20),

                  // 分组列表
                  if (_sets.isEmpty)
                    Center(
                      child: Text(l10n.noHistoryYet,
                          style: const TextStyle(color: AppColors.textHint)),
                    )
                  else
                    ...grouped.entries.map(
                      (entry) => _ExerciseBlock(
                        name: entry.key,
                        sets: entry.value,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final Workout workout;

  const _SummaryRow({required this.workout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final durationMin = workout.durationSeconds != null
        ? (workout.durationSeconds! / 60).round()
        : null;

    return Row(
      children: [
        _SumItem(
          label: l10n.workoutSets(workout.totalSets),
          icon: Icons.fitness_center,
        ),
        const SizedBox(width: 20),
        _SumItem(
          label: '${workout.totalVolume.toStringAsFixed(0)} kg',
          icon: Icons.monitor_weight_outlined,
        ),
        if (durationMin != null) ...[
          const SizedBox(width: 20),
          _SumItem(
            label: '${durationMin}min',
            icon: Icons.timer_outlined,
          ),
        ],
      ],
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SumItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final String name;
  final List<WorkoutSet> sets;

  const _ExerciseBlock({required this.name, required this.sets});

  @override
  Widget build(BuildContext context) {
    final totalVol = sets.fold<double>(0, (sum, s) => sum + s.weight * s.reps);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Text(
                '${totalVol.toStringAsFixed(0)} kg vol',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...sets.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final weightStr = s.weight % 1 == 0
                ? s.weight.toInt().toString()
                : s.weight.toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$weightStr kg × ${s.reps}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
