class Workout {
  final int? id;
  final String startedAt;
  final String? endedAt;
  final String muscleGroups; // 逗号分隔，如 "chest,triceps"
  final String? notes;
  final int? durationSeconds;
  final int totalSets;
  final double totalVolume;

  const Workout({
    this.id,
    required this.startedAt,
    this.endedAt,
    this.muscleGroups = '',
    this.notes,
    this.durationSeconds,
    this.totalSets = 0,
    this.totalVolume = 0.0,
  });

  bool get isActive => endedAt == null;

  List<String> get muscleGroupList =>
      muscleGroups.isEmpty ? [] : muscleGroups.split(',');

  Workout copyWith({
    int? id,
    String? endedAt,
    String? muscleGroups,
    int? durationSeconds,
    int? totalSets,
    double? totalVolume,
  }) =>
      Workout(
        id: id ?? this.id,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        muscleGroups: muscleGroups ?? this.muscleGroups,
        notes: notes,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        totalSets: totalSets ?? this.totalSets,
        totalVolume: totalVolume ?? this.totalVolume,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'started_at': startedAt,
        'ended_at': endedAt,
        'muscle_groups': muscleGroups,
        'notes': notes,
        'duration_seconds': durationSeconds,
        'total_sets': totalSets,
        'total_volume': totalVolume,
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'] as int?,
        startedAt: map['started_at'] as String,
        endedAt: map['ended_at'] as String?,
        muscleGroups: (map['muscle_groups'] as String?) ?? '',
        notes: map['notes'] as String?,
        durationSeconds: map['duration_seconds'] as int?,
        totalSets: (map['total_sets'] as int?) ?? 0,
        totalVolume: (map['total_volume'] as num?)?.toDouble() ?? 0.0,
      );
}
