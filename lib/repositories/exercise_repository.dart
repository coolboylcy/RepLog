import '../data/database_helper.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final DatabaseHelper _db;

  ExerciseRepository(this._db);

  Future<List<Exercise>> getAll() async {
    final rows = await _db.db.query('exercises', orderBy: 'muscle_group, sort_order');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<List<Exercise>> getByMuscleGroup(String muscleGroup) async {
    final rows = await _db.db.query(
      'exercises',
      where: 'muscle_group = ?',
      whereArgs: [muscleGroup],
      orderBy: 'sort_order',
    );
    return rows.map(Exercise.fromMap).toList();
  }

  /// 根据最近使用频率返回动作列表（通过 workout_sets 表关联）
  Future<List<Exercise>> getRecentlyUsed(String muscleGroup, {int limit = 8}) async {
    final rows = await _db.db.rawQuery('''
      SELECT e.*, MAX(ws.created_at) AS last_used
      FROM exercises e
      INNER JOIN workout_sets ws ON ws.exercise_id = e.id
      WHERE e.muscle_group = ?
      GROUP BY e.id
      ORDER BY last_used DESC
      LIMIT ?
    ''', [muscleGroup, limit]);
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getById(int id) async {
    final rows = await _db.db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  Future<Exercise> insert(Exercise exercise) async {
    final now = DateTime.now().toIso8601String();
    final id = await _db.db.insert('exercises', exercise.copyWith(id: null).toMap()
      ..['created_at'] = now);
    return exercise.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    await _db.db.delete('exercises', where: 'id = ? AND is_custom = 1', whereArgs: [id]);
  }
}
