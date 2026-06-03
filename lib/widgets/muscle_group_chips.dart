import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';

const kMuscleGroups = [
  'chest',
  'back',
  'shoulders',
  'legs',
  'arms',
  'core',
  'full_body',
];

String muscleGroupLabel(BuildContext context, String group) {
  final l10n = AppLocalizations.of(context)!;
  switch (group) {
    case 'chest':
      return l10n.muscleChest;
    case 'back':
      return l10n.muscleBack;
    case 'shoulders':
      return l10n.muscleShoulders;
    case 'legs':
      return l10n.muscleLegs;
    case 'arms':
      return l10n.muscleArms;
    case 'core':
      return l10n.muscleCore;
    case 'full_body':
      return l10n.muscleFullBody;
    default:
      return group;
  }
}

class MuscleGroupChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const MuscleGroupChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kMuscleGroups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final group = kMuscleGroups[i];
          final isSelected = group == selected;
          final color = AppColors.forMuscleGroup(group);

          return FilterChip(
            label: Text(
              muscleGroupLabel(context, group),
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(group),
            backgroundColor: color.withValues(alpha: 0.1),
            selectedColor: color,
            checkmarkColor: Colors.white,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            side: BorderSide(
                color: color.withValues(alpha: isSelected ? 0 : 0.4)),
          );
        },
      ),
    );
  }
}

/// 只读标签（用于历史页等）
class MuscleGroupTag extends StatelessWidget {
  final String muscleGroup;
  final double fontSize;

  const MuscleGroupTag({
    super.key,
    required this.muscleGroup,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forMuscleGroup(muscleGroup);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        muscleGroupLabel(context, muscleGroup),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
