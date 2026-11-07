import '../data/database_helper.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';

class WorkoutRepository {
  final DatabaseHelper _db;

  WorkoutRepository(this._db);

  Future<List<Workout>> getAllWorkouts() async {
    final maps = await _db.db.query('workouts', orderBy: 'date DESC');
    return maps.map(Workout.fromMap).toList();
  }

  Future<List<Workout>> getRecentWorkouts({int limit = 10}) async {
    final maps = await _db.db.query(
      'workouts',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(Workout.fromMap).toList();
  }

  Future<Workout?> getWorkoutById(int id) async {
    final maps = await _db.db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Workout.fromMap(maps.first);
  }

  Future<int> insertWorkout(Workout workout) async {
    return _db.db.insert('workouts', workout.toMap());
  }

  Future<void> updateWorkout(Workout workout) async {
    await _db.db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(int id) async {
    await _db.db.delete('workout_sets', where: 'workout_id = ?', whereArgs: [id]);
    await _db.db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutId) async {
    final maps = await _db.db.rawQuery('''
      SELECT ws.*, e.name_zh, e.name_en, e.muscle_group
      FROM workout_sets ws
      JOIN exercises e ON ws.exercise_id = e.id
      WHERE ws.workout_id = ?
      ORDER BY ws.set_number
    ''', [workoutId]);
    return maps.map(WorkoutSet.fromMap).toList();
  }

  Future<int> insertSet(WorkoutSet set) async {
    return _db.db.insert('workout_sets', set.toMap());
  }

  Future<void> deleteSet(int id) async {
    await _db.db.delete('workout_sets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateWorkoutStats(int workoutId) async {
    final sets = await getSetsForWorkout(workoutId);
    final totalSets = sets.length;
    final totalVolume = sets.fold<double>(0, (sum, s) => sum + s.volume);
    await _db.db.update(
      'workouts',
      {'total_sets': totalSets, 'total_volume': totalVolume},
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }
}
