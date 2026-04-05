import '../data/database_helper.dart';
import '../models/workout.dart';

class WorkoutRepository {
  final DatabaseHelper _db;

  WorkoutRepository(this._db);

  Future<Workout> insert(Workout workout) async {
    final id = await _db.db.insert('workouts', workout.toMap());
    return workout.copyWith(id: id);
  }

  Future<Workout?> getActive() async {
    final rows = await _db.db.query(
      'workouts',
      where: 'ended_at IS NULL',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Workout.fromMap(rows.first);
  }

  Future<List<Workout>> getRecent({int limit = 5}) async {
    final rows = await _db.db.query(
      'workouts',
      where: 'ended_at IS NOT NULL',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return rows.map(Workout.fromMap).toList();
  }

  Future<List<Workout>> getAll() async {
    final rows = await _db.db.query(
      'workouts',
      where: 'ended_at IS NOT NULL',
      orderBy: 'started_at DESC',
    );
    return rows.map(Workout.fromMap).toList();
  }

  Future<Workout?> getById(int id) async {
    final rows = await _db.db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Workout.fromMap(rows.first);
  }

  Future<void> update(Workout workout) async {
    await _db.db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> delete(int id) async {
    await _db.db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }
}
