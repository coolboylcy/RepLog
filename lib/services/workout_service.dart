import '../models/workout.dart';
import '../models/workout_set.dart';
import '../repositories/workout_repository.dart';

class WorkoutService {
  final WorkoutRepository _repo;

  WorkoutService(this._repo);

  Future<List<Workout>> getAllWorkouts() => _repo.getAllWorkouts();

  Future<List<Workout>> getRecentWorkouts({int limit = 10}) =>
      _repo.getRecentWorkouts(limit: limit);

  Future<Workout?> getWorkoutById(int id) => _repo.getWorkoutById(id);

  Future<int> startWorkout({String? templateName}) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _repo.insertWorkout(Workout(
      date: dateStr,
      templateName: templateName,
    ));
  }

  Future<void> finishWorkout(int workoutId, int durationMinutes) async {
    await _repo.updateWorkoutStats(workoutId);
    final workout = await _repo.getWorkoutById(workoutId);
    if (workout != null) {
      await _repo.updateWorkout(Workout(
        id: workout.id,
        date: workout.date,
        durationMinutes: durationMinutes,
        templateName: workout.templateName,
        totalSets: workout.totalSets,
        totalVolume: workout.totalVolume,
      ));
    }
  }

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutId) =>
      _repo.getSetsForWorkout(workoutId);

  Future<int> addSet({
    required int workoutId,
    required int exerciseId,
    required int setNumber,
    required double weight,
    required int reps,
    bool isWarmup = false,
  }) async {
    final id = await _repo.insertSet(WorkoutSet(
      workoutId: workoutId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      isWarmup: isWarmup,
    ));
    await _repo.updateWorkoutStats(workoutId);
    return id;
  }

  Future<void> deleteSet(int setId, int workoutId) async {
    await _repo.deleteSet(setId);
    await _repo.updateWorkoutStats(workoutId);
  }

  Future<void> deleteWorkout(int id) => _repo.deleteWorkout(id);
}
