import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../services/stats_service.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/week_activity_row.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with AutomaticKeepAliveClientMixin {
  WorkoutStats? _stats;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final svc = ServiceLocator.of(context).statsService;
    final stats = await svc.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  String _formatVolume(double vol) {
    if (vol >= 1000000) return '${(vol / 1000000).toStringAsFixed(1)}M';
    if (vol >= 1000) return '${(vol / 1000).toStringAsFixed(1)}k';
    return vol.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null || _stats!.totalDays == 0
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noInsightsYet,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textHint, height: 1.6),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 4个统计卡片
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            StatCard(
                              label: l10n.totalTrainingDays,
                              value: _stats!.totalDays.toString(),
                              icon: Icons.calendar_month,
                              color: AppColors.primary,
                            ),
                            StatCard(
                              label: l10n.totalSets,
                              value: _stats!.totalSets.toString(),
                              icon: Icons.fitness_center,
                              color: AppColors.accent,
                            ),
                            StatCard(
                              label: l10n.totalVolume,
                              value: '${_formatVolume(_stats!.totalVolume)} kg',
                              icon: Icons.monitor_weight_outlined,
                              color: AppColors.muscleLegs,
                            ),
                            StatCard(
                              label: l10n.currentStreak,
                              value: '${_stats!.currentStreak}w',
                              icon: Icons.local_fire_department,
                              color: AppColors.warning,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 近期活动
                        Text(l10n.recentActivity,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              WeekActivityRow(activity: _stats!.weekActivity),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
