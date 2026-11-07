import '../data/database_helper.dart';

class StatsRepository {
  final DatabaseHelper _db;

  StatsRepository(this._db);

  Future<int> getTotalWorkouts() async {
    final result = await _db.db.rawQuery('SELECT COUNT(*) as cnt FROM workouts');
    return result.first['cnt'] as int? ?? 0;
  }

  Future<double> getTotalVolume() async {
    final result = await _db.db.rawQuery('SELECT SUM(total_volume) as total FROM workouts');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> getCurrentStreak() async {
    final currentWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', 'now', 'localtime') AS w");
    final currentWeek = currentWeekRow.first['w'] as String;

    final lastWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', date('now', 'localtime', '-7 days')) AS w");
    final lastWeek = lastWeekRow.first['w'] as String;

    final hasCurrentWeek = await _db.db.rawQuery('''
      SELECT COUNT(*) as cnt FROM workouts
      WHERE strftime('%Y-%W', date) = ?
    ''', [currentWeek]);

    final hasLastWeek = await _db.db.rawQuery('''
      SELECT COUNT(*) as cnt FROM workouts
      WHERE strftime('%Y-%W', date) = ?
    ''', [lastWeek]);

    final currentCount = hasCurrentWeek.first['cnt'] as int? ?? 0;
    final lastCount = hasLastWeek.first['cnt'] as int? ?? 0;

    if (currentCount == 0 && lastCount == 0) return 0;

    int streak = 0;
    if (currentCount > 0) streak = 1;

    final weeks = await _db.db.rawQuery('''
      SELECT DISTINCT strftime('%Y-%W', date) as week
      FROM workouts
      ORDER BY week DESC
    ''');

    final weekStrings = weeks.map((w) => w['week'] as String).toList();
    if (weekStrings.isEmpty) return streak;

    final startIndex = currentCount > 0 ? 1 : 0;
    final startWeek = currentCount > 0 ? currentWeek : lastWeek;

    if (startIndex == 0 && lastCount > 0) {
      streak = 1;
    }

    for (var i = startIndex; i < weekStrings.length; i++) {
      if (i == 0) continue;
      streak++;
    }

    return streak > 0 ? streak : (currentCount > 0 || lastCount > 0 ? 1 : 0);
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory(int exerciseId) async {
    return _db.db.rawQuery('''
      SELECT ws.*, w.date, e.name_zh, e.name_en
      FROM workout_sets ws
      JOIN workouts w ON ws.workout_id = w.id
      JOIN exercises e ON ws.exercise_id = e.id
      WHERE ws.exercise_id = ?
      ORDER BY w.date DESC, ws.set_number
    ''', [exerciseId]);
  }

  Future<Map<String, dynamic>?> getExercisePR(int exerciseId) async {
    final maxWeight = await _db.db.rawQuery('''
      SELECT MAX(weight) as max_weight FROM workout_sets
      WHERE exercise_id = ?
    ''', [exerciseId]);

    final maxVolume = await _db.db.rawQuery('''
      SELECT MAX(weight * reps) as max_volume FROM workout_sets
      WHERE exercise_id = ?
    ''', [exerciseId]);

    final mw = (maxWeight.first['max_weight'] as num?)?.toDouble();
    final mv = (maxVolume.first['max_volume'] as num?)?.toDouble();
    if (mw == null && mv == null) return null;

    return {'max_weight': mw ?? 0, 'max_volume': mv ?? 0};
  }

  Future<Map<String, int>> getMuscleGroupDistribution() async {
    final result = await _db.db.rawQuery('''
      SELECT e.muscle_group, COUNT(*) as cnt
      FROM workout_sets ws
      JOIN exercises e ON ws.exercise_id = e.id
      GROUP BY e.muscle_group
      ORDER BY cnt DESC
    ''');

    final map = <String, int>{};
    for (final row in result) {
      map[row['muscle_group'] as String] = row['cnt'] as int;
    }
    return map;
  }

  Future<Map<String, dynamic>> getWeekComparison() async {
    final currentWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', 'now', 'localtime') AS w");
    final currentWeek = currentWeekRow.first['w'] as String;

    final lastWeekRow = await _db.db.rawQuery(
        "SELECT strftime('%Y-%W', date('now', 'localtime', '-7 days')) AS w");
    final lastWeek = lastWeekRow.first['w'] as String;

    final thisWeekSets = await _db.db.rawQuery('''
      SELECT COUNT(*) as cnt FROM workout_sets ws
      JOIN workouts w ON ws.workout_id = w.id
      WHERE strftime('%Y-%W', w.date) = ?
    ''', [currentWeek]);

    final lastWeekSets = await _db.db.rawQuery('''
      SELECT COUNT(*) as cnt FROM workout_sets ws
      JOIN workouts w ON ws.workout_id = w.id
      WHERE strftime('%Y-%W', w.date) = ?
    ''', [lastWeek]);

    final thisWeekVolume = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(ws.weight * ws.reps), 0) as vol FROM workout_sets ws
      JOIN workouts w ON ws.workout_id = w.id
      WHERE strftime('%Y-%W', w.date) = ?
    ''', [currentWeek]);

    final lastWeekVolume = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(ws.weight * ws.reps), 0) as vol FROM workout_sets ws
      JOIN workouts w ON ws.workout_id = w.id
      WHERE strftime('%Y-%W', w.date) = ?
    ''', [lastWeek]);

    return {
      'this_week_sets': thisWeekSets.first['cnt'] as int? ?? 0,
      'last_week_sets': lastWeekSets.first['cnt'] as int? ?? 0,
      'this_week_volume': (thisWeekVolume.first['vol'] as num?)?.toDouble() ?? 0,
      'last_week_volume': (lastWeekVolume.first['vol'] as num?)?.toDouble() ?? 0,
    };
  }
}
