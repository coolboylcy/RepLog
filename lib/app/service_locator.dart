import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/workout_repository.dart';
import '../repositories/set_repository.dart';
import '../repositories/template_repository.dart';
import '../repositories/stats_repository.dart';
import '../services/workout_service.dart';
import '../services/exercise_service.dart';
import '../services/stats_service.dart';
import '../services/locale_service.dart';

class ServiceLocator extends InheritedWidget {
  final DatabaseHelper database;
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final SetRepository setRepository;
  final TemplateRepository templateRepository;
  final StatsRepository statsRepository;
  final WorkoutService workoutService;
  final ExerciseService exerciseService;
  final StatsService statsService;
  final LocaleService localeService;

  const ServiceLocator({
    super.key,
    required super.child,
    required this.database,
    required this.exerciseRepository,
    required this.workoutRepository,
    required this.setRepository,
    required this.templateRepository,
    required this.statsRepository,
    required this.workoutService,
    required this.exerciseService,
    required this.statsService,
    required this.localeService,
  });

  static ServiceLocator of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ServiceLocator>();
    assert(result != null, 'No ServiceLocator found in context');
    return result!;
  }

  static Future<ServiceLocator Function(Widget child)> initialize() async {
    final database = DatabaseHelper();
    await database.init();

    final exerciseRepo = ExerciseRepository(database);
    final workoutRepo = WorkoutRepository(database);
    final setRepo = SetRepository(database);
    final templateRepo = TemplateRepository(database);
    final statsRepo = StatsRepository(database);

    final workoutService = WorkoutService(workoutRepo, setRepo);
    final exerciseService = ExerciseService(exerciseRepo, setRepo);
    final statsService = StatsService(statsRepo);
    final localeService = LocaleService();
    await localeService.init();

    return (Widget child) => ServiceLocator(
          database: database,
          exerciseRepository: exerciseRepo,
          workoutRepository: workoutRepo,
          setRepository: setRepo,
          templateRepository: templateRepo,
          statsRepository: statsRepo,
          workoutService: workoutService,
          exerciseService: exerciseService,
          statsService: statsService,
          localeService: localeService,
          child: child,
        );
  }

  @override
  bool updateShouldNotify(ServiceLocator oldWidget) => false;
}
