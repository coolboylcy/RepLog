import '../models/workout.dart';
import '../models/workout_set.dart';
import '../repositories/workout_repository.dart';
import '../repositories/set_repository.dart';

class WorkoutService {
  final WorkoutRepository _workoutRepo;
  final SetRepository _setRepo;

  WorkoutService(this._workoutRepo, this._setRepo);

  /// 开始新训练，若已有进行中的训练则直接返回
  Future<Workout> startWorkout() async {
    final active = await _workoutRepo.getActive();
    if (active != null) return active;

    final now = DateTime.now().toIso8601String();
    final workout = Workout(startedAt: now);
    return _workoutRepo.insert(workout);
  }

  /// 获取当前进行中的训练
  Future<Workout?> getActive() => _workoutRepo.getActive();

  /// 记录一组，并更新训练的反范式计数器
  Future<WorkoutSet> logSet({
    required int workoutId,
    required int exerciseId,
    required String exerciseName,
    required String muscleGroup,
    required double weight,
    required int reps,
  }) async {
    final now = DateTime.now().toIso8601String();
    final nextOrder = await _setRepo.getNextSetOrder(workoutId);

    final set = WorkoutSet(
      workoutId: workoutId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      weight: weight,
      reps: reps,
      setOrder: nextOrder,
      createdAt: now,
    );
    final saved = await _setRepo.insert(set);

    // 更新训练的反范式计数器（在事务中）
    await _updateWorkoutCounters(workoutId, weight * reps, 1);

    return saved;
  }

  /// 删除某组，并更新计数器
  Future<void> deleteSet(WorkoutSet set) async {
    await _setRepo.delete(set.id!);
    await _updateWorkoutCounters(set.workoutId, -(set.weight * set.reps), -1);
  }

  Future<void> _updateWorkoutCounters(
      int workoutId, double volumeDelta, int setsDelta) async {
    final workout = await _workoutRepo.getById(workoutId);
    if (workout == null) return;
    await _workoutRepo.update(workout.copyWith(
      totalSets: (workout.totalSets + setsDelta).clamp(0, 99999),
      totalVolume: (workout.totalVolume + volumeDelta).clamp(0, double.infinity),
    ));
  }

  /// 结束训练
  Future<Workout> endWorkout(int workoutId) async {
    final workout = await _workoutRepo.getById(workoutId);
    if (workout == null) throw StateError('Workout $workoutId not found');

    final now = DateTime.now();
    final start = DateTime.parse(workout.startedAt);
    final duration = now.difference(start).inSeconds;

    // 从已记录的组数推算涉及的肌群
    final sets = await _setRepo.getByWorkoutId(workoutId);
    final muscleGroups =
        sets.map((s) => s.muscleGroup).toSet().join(',');

    final updated = workout.copyWith(
      endedAt: now.toIso8601String(),
      durationSeconds: duration,
      muscleGroups: muscleGroups,
    );
    await _workoutRepo.update(updated);
    return updated;
  }

  /// 放弃训练（没有记录任何组数时直接删除）
  Future<void> discardWorkout(int workoutId) async {
    await _workoutRepo.delete(workoutId);
  }

  /// 获取某个动作的上次训练记录（用于智能默认值）
  Future<List<WorkoutSet>> getLastSetsForExercise(int exerciseId) =>
      _setRepo.getLastSetsForExercise(exerciseId, limit: 5);

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutId) =>
      _setRepo.getByWorkoutId(workoutId);

  Future<List<Workout>> getRecentWorkouts({int limit = 10}) =>
      _workoutRepo.getRecent(limit: limit);

  Future<List<Workout>> getAllWorkouts() => _workoutRepo.getAll();
}
