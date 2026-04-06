import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/workout_set.dart';
import '../theme/app_colors.dart';

/// 本次训练已记录的组数列表（按动作分组）
class SessionSetList extends StatelessWidget {
  final List<WorkoutSet> sets;
  final bool isKg;
  final Future<void> Function(WorkoutSet) onDelete;

  const SessionSetList({
    super.key,
    required this.sets,
    required this.isKg,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) return const SizedBox.shrink();

    // 按动作分组
    final grouped = <String, List<WorkoutSet>>{};
    for (final s in sets) {
      grouped.putIfAbsent(s.exerciseName, () => []).add(s);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final name = grouped.keys.elementAt(i);
        final groupSets = grouped[name]!;
        return _ExerciseGroup(
          name: name,
          sets: groupSets,
          isKg: isKg,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _ExerciseGroup extends StatelessWidget {
  final String name;
  final List<WorkoutSet> sets;
  final bool isKg;
  final Future<void> Function(WorkoutSet) onDelete;

  const _ExerciseGroup({
    required this.name,
    required this.sets,
    required this.isKg,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = isKg ? l10n.kg : l10n.lb;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          ...sets.asMap().entries.map((entry) {
            final idx = entry.key;
            final set = entry.value;
            final weightStr = set.weight % 1 == 0
                ? set.weight.toInt().toString()
                : set.weight.toStringAsFixed(1);

            return Dismissible(
              key: ValueKey(set.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
              confirmDismiss: (_) async {
                await onDelete(set);
                return false; // 让上层重建列表
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$weightStr$unit × ${set.reps}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(set.weight * set.reps).toStringAsFixed(0)}$unit',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
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
