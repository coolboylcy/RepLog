import '../data/database_helper.dart';

class StatsRepository {
  final DatabaseHelper _db;

  StatsRepository(this._db);

  Future<int> getTotalDays() async {
    final result = await _db.db.rawQuery('''
      SELECT COUNT(DISTINCT DATE(started_at)) AS days
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return (result.first['days'] as int?) ?? 0;
  }

  Future<int> getTotalSets() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_sets), 0) AS total
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  Future<double> getTotalVolume() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_volume), 0) AS volume
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return ((result.first['volume'] as num?) ?? 0).toDouble();
  }

  Future<List<bool>> getRecentActivity({int days = 7}) async {
    final now = DateTime.now();
    final result = await _db.db.rawQuery('''
      SELECT DISTINCT DATE(started_at) AS training_date
      FROM workouts
      WHERE ended_at IS NOT NULL
        AND DATE(started_at) >= DATE(?, '-${days - 1} days')
      ORDER BY training_date ASC
    ''', [now.toIso8601String()]);

    final trainingDates = result.map((r) => r['training_date'] as String).toSet();

    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return trainingDates.contains(dateStr);
    });
  }

  Future<int> getCurrentStreak() async {
    // Use SQLite's strftime to avoid Dart/SQLite week-numbering mismatch
    final currentWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', 'now', 'localtime') AS w");
    final currentWeek = currentWeekRow.first['w'] as String;
    final lastWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', date('now', 'localtime', '-7 days')) AS w");
    final lastWeek = lastWeekRow.first['w'] as String;

    final result = await _db.db.rawQuery('''
      SELECT DISTINCT strftime('%Y-%W', started_at) AS week
      FROM workouts
      WHERE ended_at IS NOT NULL
      ORDER BY week DESC
    ''');

    if (result.isEmpty) return 0;

    final weeks = result.map((r) => r['week'] as String).toList();

    if (weeks.first != currentWeek && weeks.first != lastWeek) return 0;

    int streak = 1;
    for (int i = 0; i < weeks.length - 1; i++) {
      final current = _parseWeek(weeks[i]);
      final prev = _parseWeek(weeks[i + 1]);
      final diff = current.difference(prev).inDays;
      if (diff >= 6 && diff <= 8) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  DateTime _parseWeek(String yearWeek) {
    final parts = yearWeek.split('-');
    final year = int.parse(parts[0]);
    final week = int.parse(parts[1]);
    final jan1 = DateTime(year, 1, 1);
    return jan1.add(Duration(days: (week - 1) * 7));
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory(int exerciseId) async {
    return await _db.db.rawQuery('''
      SELECT ws.weight, ws.reps, ws.set_order, w.started_at
      FROM workout_sets ws
      JOIN workouts w ON w.id = ws.workout_id
      WHERE ws.exercise_id = ? AND w.ended_at IS NOT NULL
      ORDER BY w.started_at DESC, ws.set_order ASC
    ''', [exerciseId]);
  }

  Future<Map<String, double>> getExercisePR(int exerciseId) async {
    final result = await _db.db.rawQuery('''
      SELECT MAX(weight) AS max_weight,
             MAX(weight * reps) AS max_volume
      FROM workout_sets ws
      JOIN workouts w ON w.id = ws.workout_id
      WHERE ws.exercise_id = ? AND w.ended_at IS NOT NULL
    ''', [exerciseId]);
    if (result.isEmpty) return {'max_weight': 0, 'max_volume': 0};
    return {
      'max_weight': ((result.first['max_weight'] as num?) ?? 0).toDouble(),
      'max_volume': ((result.first['max_volume'] as num?) ?? 0).toDouble(),
    };
  }

  Future<Map<String, int>> getMuscleGroupDistribution() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    final result = await _db.db.rawQuery('''
      SELECT ws.muscle_group, COUNT(*) AS cnt
      FROM workout_sets ws
      JOIN workouts w ON w.id = ws.workout_id
      WHERE w.ended_at IS NOT NULL AND w.started_at >= ?
      GROUP BY ws.muscle_group
    ''', [cutoff]);
    return {
      for (final r in result)
        r['muscle_group'] as String: (r['cnt'] as int)
    };
  }

  Future<Map<String, int>> getWeekComparison() async {
    final now = DateTime.now();
    final startOfThisWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 7));

    String toDateStr(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final thisResult = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_sets), 0) AS total
      FROM workouts
      WHERE ended_at IS NOT NULL
        AND DATE(started_at) >= ?
    ''', [toDateStr(startOfThisWeek)]);

    final lastResult = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_sets), 0) AS total
      FROM workouts
      WHERE ended_at IS NOT NULL
        AND DATE(started_at) >= ?
        AND DATE(started_at) < ?
    ''', [toDateStr(startOfLastWeek), toDateStr(startOfThisWeek)]);

    return {
      'this_week': (thisResult.first['total'] as int?) ?? 0,
      'last_week': (lastResult.first['total'] as int?) ?? 0,
    };
  }
}
