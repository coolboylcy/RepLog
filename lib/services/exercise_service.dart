import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/set_repository.dart';

class ExerciseService {
  final ExerciseRepository _exerciseRepo;
  final SetRepository _setRepo;

  ExerciseService(this._exerciseRepo, this._setRepo);

  Future<List<Exercise>> getByMuscleGroup(String muscleGroup) =>
      _exerciseRepo.getByMuscleGroup(muscleGroup);

  Future<List<Exercise>> getRecentlyUsed(String muscleGroup) =>
      _exerciseRepo.getRecentlyUsed(muscleGroup, limit: 8);

  Future<List<Exercise>> getAll() => _exerciseRepo.getAll();

  Future<Exercise> addCustomExercise({
    required String nameZh,
    required String nameEn,
    required String muscleGroup,
  }) {
    final exercise = Exercise(
      nameZh: nameZh,
      nameEn: nameEn,
      muscleGroup: muscleGroup,
      isCustom: true,
      createdAt: DateTime.now().toIso8601String(),
    );
    return _exerciseRepo.insert(exercise);
  }
}
