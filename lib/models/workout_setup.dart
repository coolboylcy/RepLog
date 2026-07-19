import 'exercise.dart';

enum TrainingGoal {
  strength,
  hypertrophy,
  endurance,
}

extension TrainingGoalText on TrainingGoal {
  String get storageKey => switch (this) {
        TrainingGoal.strength => 'strength',
        TrainingGoal.hypertrophy => 'hypertrophy',
        TrainingGoal.endurance => 'endurance',
      };

  String label(String locale) {
    final zh = locale.startsWith('zh');
    return switch (this) {
      TrainingGoal.strength => zh ? '力量' : 'Strength',
      TrainingGoal.hypertrophy => zh ? '增肌' : 'Hypertrophy',
      TrainingGoal.endurance => zh ? '耐力' : 'Endurance',
    };
  }

  String repHint(String locale) {
    final zh = locale.startsWith('zh');
    return switch (this) {
      TrainingGoal.strength => zh ? '低次数，高强度' : 'Low reps, high load',
      TrainingGoal.hypertrophy =>
        zh ? '中等次数，稳定容量' : 'Moderate reps, steady volume',
      TrainingGoal.endurance =>
        zh ? '高次数，控制节奏' : 'Higher reps, controlled pace',
    };
  }

  static TrainingGoal fromStorage(String? value) {
    return TrainingGoal.values.firstWhere(
      (goal) => goal.storageKey == value,
      orElse: () => TrainingGoal.hypertrophy,
    );
  }
}

class WorkoutSetup {
  final TrainingGoal goal;
  final String primaryMuscleGroup;
  final List<PlannedExercise> exercises;
  final String createdAt;

  const WorkoutSetup({
    required this.goal,
    required this.primaryMuscleGroup,
    required this.exercises,
    required this.createdAt,
  });
}

class PlannedExercise {
  final Exercise exercise;
  final String muscleGroup;
  final TrainingGoal goal;
  final double recommendedWeight;
  final int targetReps;
  final int targetSets;
  final String recommendationReason;

  const PlannedExercise({
    required this.muscleGroup,
    required this.exercise,
    required this.goal,
    required this.recommendedWeight,
    required this.targetReps,
    required this.targetSets,
    required this.recommendationReason,
  });

  PlannedExercise copyWith({
    double? recommendedWeight,
    int? targetReps,
    int? targetSets,
  }) {
    return PlannedExercise(
      muscleGroup: muscleGroup,
      exercise: exercise,
      goal: goal,
      recommendedWeight: recommendedWeight ?? this.recommendedWeight,
      targetReps: targetReps ?? this.targetReps,
      targetSets: targetSets ?? this.targetSets,
      recommendationReason: recommendationReason,
    );
  }
}
