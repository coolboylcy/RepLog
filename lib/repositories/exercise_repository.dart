import '../data/database_helper.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final DatabaseHelper _db;

  ExerciseRepository(this._db);

  Future<List<Exercise>> getAllExercises() async {
    final maps = await _db.db.query('exercises', orderBy: 'muscle_group, name_zh');
    return maps.map(Exercise.fromMap).toList();
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final maps = await _db.db.query(
      'exercises',
      where: 'muscle_group = ?',
      whereArgs: [muscleGroup],
      orderBy: 'name_zh',
    );
    return maps.map(Exercise.fromMap).toList();
  }

  Future<List<Exercise>> getCustomExercises() async {
    final maps = await _db.db.query(
      'exercises',
      where: 'is_custom = 1',
      orderBy: 'name_zh',
    );
    return maps.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    final maps = await _db.db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Exercise.fromMap(maps.first);
  }

  Future<int> insertExercise(Exercise exercise) async {
    return _db.db.insert('exercises', exercise.toMap());
  }

  Future<void> deleteExercise(int id) async {
    await _db.db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}
