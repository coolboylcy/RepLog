class TemplateItem {
  final int? id;
  final int templateId;
  final int exerciseId;
  final int defaultSets;
  final int defaultReps;
  final int sortOrder;

  const TemplateItem({
    this.id,
    required this.templateId,
    required this.exerciseId,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'template_id': templateId,
        'exercise_id': exerciseId,
        'default_sets': defaultSets,
        'default_reps': defaultReps,
        'sort_order': sortOrder,
      };

  factory TemplateItem.fromMap(Map<String, dynamic> map) => TemplateItem(
        id: map['id'] as int?,
        templateId: map['template_id'] as int,
        exerciseId: map['exercise_id'] as int,
        defaultSets: map['default_sets'] as int,
        defaultReps: map['default_reps'] as int,
        sortOrder: map['sort_order'] as int,
      );
}
