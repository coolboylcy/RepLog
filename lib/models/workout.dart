class Workout {
  final int? id;
  final String date;
  final int durationMinutes;
  final String? templateName;
  final int totalSets;
  final double totalVolume;

  const Workout({
    this.id,
    required this.date,
    this.durationMinutes = 0,
    this.templateName,
    this.totalSets = 0,
    this.totalVolume = 0,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      date: map['date'] as String,
      durationMinutes: map['duration_minutes'] as int? ?? 0,
      templateName: map['template_name'] as String?,
      totalSets: map['total_sets'] as int? ?? 0,
      totalVolume: (map['total_volume'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'duration_minutes': durationMinutes,
      'template_name': templateName,
      'total_sets': totalSets,
      'total_volume': totalVolume,
    };
  }
}
