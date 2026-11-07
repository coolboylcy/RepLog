class WorkoutSet {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final int setNumber;
  final double weight;
  final int reps;
  final bool isWarmup;
  final String? exerciseNameZh;
  final String? exerciseNameEn;
  final String? muscleGroup;

  const WorkoutSet({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isWarmup = false,
    this.exerciseNameZh,
    this.exerciseNameEn,
    this.muscleGroup,
  });

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      exerciseId: map['exercise_id'] as int,
      setNumber: map['set_number'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      isWarmup: (map['is_warmup'] as int?) == 1,
      exerciseNameZh: map['name_zh'] as String?,
      exerciseNameEn: map['name_en'] as String?,
      muscleGroup: map['muscle_group'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'is_warmup': isWarmup ? 1 : 0,
    };
  }

  double get volume => weight * reps;
}
