import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../theme/app_colors.dart';
import 'muscle_group_chips.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutCard({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(workout.startedAt);
    final dateStr = DateFormat(locale.startsWith('zh') ? 'MM月dd日 E' : 'E, MMM d',
            locale.startsWith('zh') ? 'zh_CN' : 'en_US')
        .format(date);

    final durationStr = workout.durationSeconds != null
        ? _formatDuration(workout.durationSeconds!)
        : null;

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
                  Text(dateStr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  if (durationStr != null)
                    Text(durationStr,
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              // 肌群标签
              if (workout.muscleGroupList.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: workout.muscleGroupList
                      .map((g) => MuscleGroupTag(muscleGroup: g))
                      .toList(),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Stat(icon: Icons.fitness_center,
                      label: l10n.workoutSets(workout.totalSets)),
                  const SizedBox(width: 16),
                  _Stat(
                    icon: Icons.monitor_weight_outlined,
                    label: '${_formatVolume(workout.totalVolume)} kg',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    return '${m}min';
  }

  String _formatVolume(double vol) {
    if (vol >= 1000) return '${(vol / 1000).toStringAsFixed(1)}t';
    return vol.toStringAsFixed(0);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
