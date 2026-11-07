import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../di/service_provider.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  Map<String, int> _muscleDistribution = {};
  Map<String, dynamic> _weekComparison = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final dist = await sp.statsRepository.getMuscleGroupDistribution();
    final week = await sp.statsRepository.getWeekComparison();
    if (mounted) {
      setState(() {
        _muscleDistribution = dist;
        _weekComparison = week;
      });
    }
  }

  static const _muscleGroupNames = {
    'chest': '胸',
    'back': '背',
    'shoulders': '肩',
    'legs': '腿',
    'arms': '手臂',
    'core': '核心',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insights),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WeekComparisonCard(
              weekData: _weekComparison,
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            Text(l10n.muscleDistribution,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _MuscleDistributionChart(
              data: _muscleDistribution,
              groupNames: _muscleGroupNames,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekComparisonCard extends StatelessWidget {
  final Map<String, dynamic> weekData;
  final AppLocalizations l10n;

  const _WeekComparisonCard({required this.weekData, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thisWeekSets = weekData['this_week_sets'] as int? ?? 0;
    final lastWeekSets = weekData['last_week_sets'] as int? ?? 0;
    final thisWeekVol = (weekData['this_week_volume'] as num?)?.toDouble() ?? 0;
    final lastWeekVol = (weekData['last_week_volume'] as num?)?.toDouble() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.weekComparison,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(l10n.thisWeek,
                          style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text('$thisWeekSets',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(l10n.sets, style: theme.textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text('${(thisWeekVol / 1000).toStringAsFixed(1)}t',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(l10n.lastWeek,
                          style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text('$lastWeekSets',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      Text(l10n.sets, style: theme.textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text('${(lastWeekVol / 1000).toStringAsFixed(1)}t',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleDistributionChart extends StatelessWidget {
  final Map<String, int> data;
  final Map<String, String> groupNames;

  const _MuscleDistributionChart({
    required this.data,
    required this.groupNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('暂无数据',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ),
        ),
      );
    }

    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: data.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final group = entry.value.key;
            final count = entry.value.value;
            final ratio = maxVal > 0 ? count / maxVal : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      groupNames[group] ?? group,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 20,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          colors[index % colors.length],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$count',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
