class TemplateItem {
  final int? id;
  final int templateId;
  final int exerciseId;
  final int sortOrder;
  final int defaultSets;
  final int defaultReps;
  final String? exerciseNameZh;
  final String? exerciseNameEn;
  final String? muscleGroup;

  const TemplateItem({
    this.id,
    required this.templateId,
    required this.exerciseId,
    required this.sortOrder,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.exerciseNameZh,
    this.exerciseNameEn,
    this.muscleGroup,
  });

  factory TemplateItem.fromMap(Map<String, dynamic> map) {
    return TemplateItem(
      id: map['id'] as int?,
      templateId: map['template_id'] as int,
      exerciseId: map['exercise_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      defaultSets: map['default_sets'] as int? ?? 3,
      defaultReps: map['default_reps'] as int? ?? 10,
      exerciseNameZh: map['name_zh'] as String?,
      exerciseNameEn: map['name_en'] as String?,
      muscleGroup: map['muscle_group'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'template_id': templateId,
      'exercise_id': exerciseId,
      'sort_order': sortOrder,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
    };
  }
}
