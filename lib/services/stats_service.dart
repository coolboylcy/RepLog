import '../repositories/stats_repository.dart';

class WorkoutStats {
  final int totalDays;
  final int totalSets;
  final double totalVolume;
  final int currentStreak;
  final List<bool> weekActivity;

  const WorkoutStats({
    required this.totalDays,
    required this.totalSets,
    required this.totalVolume,
    required this.currentStreak,
    required this.weekActivity,
  });
}

class StatsService {
  final StatsRepository _repo;

  StatsService(this._repo);

  Future<WorkoutStats> getStats() async {
    final results = await Future.wait([
      _repo.getTotalDays(),
      _repo.getTotalSets(),
      _repo.getTotalVolume(),
      _repo.getCurrentStreak(),
      _repo.getRecentActivity(days: 7),
    ]);

    return WorkoutStats(
      totalDays: results[0] as int,
      totalSets: results[1] as int,
      totalVolume: results[2] as double,
      currentStreak: results[3] as int,
      weekActivity: results[4] as List<bool>,
    );
  }
}
