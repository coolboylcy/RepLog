import '../data/database_helper.dart';
import '../models/workout_set.dart';

class SetRepository {
  final DatabaseHelper _db;

  SetRepository(this._db);

  Future<WorkoutSet> insert(WorkoutSet set) async {
    final id = await _db.db.insert('workout_sets', set.toMap());
    return set.copyWith(id: id);
  }

  Future<List<WorkoutSet>> getByWorkoutId(int workoutId) async {
    final rows = await _db.db.query(
      'workout_sets',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'set_order',
    );
    return rows.map(WorkoutSet.fromMap).toList();
  }

  /// 获取某个动作的最近N组记录（用于智能默认值）
  Future<List<WorkoutSet>> getLastSetsForExercise(int exerciseId, {int limit = 5}) async {
    final rows = await _db.db.rawQuery('''
      SELECT ws.*
      FROM workout_sets ws
      INNER JOIN workouts w ON w.id = ws.workout_id
      WHERE ws.exercise_id = ? AND w.ended_at IS NOT NULL
      ORDER BY ws.created_at DESC
      LIMIT ?
    ''', [exerciseId, limit]);
    return rows.map(WorkoutSet.fromMap).toList();
  }

  /// 统计本次训练已记录的最大 set_order（用于自动递增）
  Future<int> getNextSetOrder(int workoutId) async {
    final result = await _db.db.rawQuery(
      'SELECT COALESCE(MAX(set_order), 0) + 1 AS next_order FROM workout_sets WHERE workout_id = ?',
      [workoutId],
    );
    return (result.first['next_order'] as int?) ?? 1;
  }

  Future<void> delete(int id) async {
    await _db.db.delete('workout_sets', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, num>> getAggregateStats() async {
    final result = await _db.db.rawQuery('''
      SELECT
        COUNT(*) AS total_sets,
        COALESCE(SUM(weight * reps), 0) AS total_volume
      FROM workout_sets ws
      INNER JOIN workouts w ON w.id = ws.workout_id
      WHERE w.ended_at IS NOT NULL
    ''');
    final row = result.first;
    return {
      'total_sets': (row['total_sets'] as num?) ?? 0,
      'total_volume': (row['total_volume'] as num?) ?? 0,
    };
  }
}
