import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_provider.dart';
import '../models/workout.dart';
import '../widgets/workout_card.dart';
import 'workout_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Workout> _workouts = [];
  bool _isKg = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final prefs = await SharedPreferences.getInstance();
    final workouts = await sp.workoutService.getAllWorkouts();
    final isKg = prefs.getString('weight_unit') != 'lb';
    if (mounted) {
      setState(() {
        _workouts = workouts;
        _isKg = isKg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        centerTitle: true,
      ),
      body: _workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history,
                      size: 64,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.noWorkouts,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _workouts.length,
                itemBuilder: (context, index) {
                  final workout = _workouts[index];
                  return WorkoutCard(
                    workout: workout,
                    isKg: _isKg,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailPage(workoutId: workout.id!),
                        ),
                      );
                      _loadData();
                    },
                  );
                },
              ),
            ),
    );
  }
}
