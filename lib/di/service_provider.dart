import 'package:flutter/widgets.dart';
import '../data/database_helper.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/workout_repository.dart';
import '../repositories/template_repository.dart';
import '../repositories/stats_repository.dart';
import '../services/exercise_service.dart';
import '../services/workout_service.dart';

class ServiceProvider extends InheritedWidget {
  final DatabaseHelper databaseHelper;
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final TemplateRepository templateRepository;
  final StatsRepository statsRepository;
  final ExerciseService exerciseService;
  final WorkoutService workoutService;

  ServiceProvider({
    super.key,
    required this.databaseHelper,
    required super.child,
  })  : exerciseRepository = ExerciseRepository(databaseHelper),
        workoutRepository = WorkoutRepository(databaseHelper),
        templateRepository = TemplateRepository(databaseHelper),
        statsRepository = StatsRepository(databaseHelper),
        exerciseService = ExerciseService(ExerciseRepository(databaseHelper)),
        workoutService = WorkoutService(WorkoutRepository(databaseHelper));

  static ServiceProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServiceProvider>()!;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) => false;
}
