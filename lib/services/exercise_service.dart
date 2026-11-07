import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseService {
  final ExerciseRepository _repo;

  ExerciseService(this._repo);

  Future<List<Exercise>> getAllExercises() => _repo.getAllExercises();

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) =>
      _repo.getExercisesByMuscleGroup(muscleGroup);

  Future<List<Exercise>> getCustomExercises() => _repo.getCustomExercises();

  Future<Exercise?> getExerciseById(int id) => _repo.getExerciseById(id);

  Future<int> addCustomExercise({
    required String nameZh,
    String? nameEn,
    required String muscleGroup,
  }) {
    return _repo.insertExercise(Exercise(
      nameZh: nameZh,
      nameEn: nameEn,
      muscleGroup: muscleGroup,
      isCustom: true,
    ));
  }

  Future<void> deleteExercise(int id) => _repo.deleteExercise(id);
}
