class WorkoutSet {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final String exerciseName; // 反范式快照
  final String muscleGroup;  // 反范式快照
  final double weight;
  final int reps;
  final int setOrder;
  final String? notes;
  final String createdAt;

  const WorkoutSet({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.weight,
    required this.reps,
    required this.setOrder,
    this.notes,
    required this.createdAt,
  });

  double get volume => weight * reps;

  WorkoutSet copyWith({int? id}) => WorkoutSet(
        id: id ?? this.id,
        workoutId: workoutId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        muscleGroup: muscleGroup,
        weight: weight,
        reps: reps,
        setOrder: setOrder,
        notes: notes,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'workout_id': workoutId,
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'muscle_group': muscleGroup,
        'weight': weight,
        'reps': reps,
        'set_order': setOrder,
        'notes': notes,
        'created_at': createdAt,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        id: map['id'] as int?,
        workoutId: map['workout_id'] as int,
        exerciseId: map['exercise_id'] as int,
        exerciseName: map['exercise_name'] as String,
        muscleGroup: map['muscle_group'] as String,
        weight: (map['weight'] as num).toDouble(),
        reps: map['reps'] as int,
        setOrder: map['set_order'] as int,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] as String,
      );
}
