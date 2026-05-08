import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/service_locator.dart';
import '../models/workout.dart';
import '../theme/app_colors.dart';
import '../widgets/workout_card.dart';
import 'workout_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  List<Workout> _workouts = [];
  bool _loading = true;
  bool _isKg = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final svc = ServiceLocator.of(context).workoutService;
    final prefs = await SharedPreferences.getInstance();
    final all = await svc.getAllWorkouts();
    if (mounted) {
      setState(() {
        _workouts = all;
        _isKg = prefs.getString('weight_unit') != 'lb';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
              ? Center(
                  child: Text(l10n.noHistoryYet,
                      style: const TextStyle(color: AppColors.textHint)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workouts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final w = _workouts[i];
                      return WorkoutCard(
                        workout: w,
                        isKg: _isKg,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailPage(workout: w),
                          ),
                        ).then((_) => _load()),
                      );
                    },
                  ),
                ),
    );
  }
}
