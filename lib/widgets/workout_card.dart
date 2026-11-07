import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final bool isKg;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.isKg = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = isKg ? 'kg' : 'lb';
    final volume = isKg
        ? workout.totalVolume
        : workout.totalVolume * 2.20462;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workout.templateName ?? '自由训练',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    workout.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.fitness_center,
                    label: '${workout.totalSets} 组',
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.monitor_weight_outlined,
                    label: '${volume.toStringAsFixed(0)} $unit',
                  ),
                  if (workout.durationMinutes > 0) ...[
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.timer_outlined,
                      label: '${workout.durationMinutes} 分钟',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
