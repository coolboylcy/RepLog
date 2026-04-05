class Exercise {
  final int? id;
  final String nameZh;
  final String nameEn;
  final String muscleGroup;
  final bool isCustom;
  final int sortOrder;
  final String createdAt;

  const Exercise({
    this.id,
    required this.nameZh,
    required this.nameEn,
    required this.muscleGroup,
    this.isCustom = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  String localizedName(String locale) =>
      locale.startsWith('zh') ? nameZh : nameEn;

  Exercise copyWith({int? id}) => Exercise(
        id: id ?? this.id,
        nameZh: nameZh,
        nameEn: nameEn,
        muscleGroup: muscleGroup,
        isCustom: isCustom,
        sortOrder: sortOrder,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name_zh': nameZh,
        'name_en': nameEn,
        'muscle_group': muscleGroup,
        'is_custom': isCustom ? 1 : 0,
        'sort_order': sortOrder,
        'created_at': createdAt,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int?,
        nameZh: map['name_zh'] as String,
        nameEn: map['name_en'] as String,
        muscleGroup: map['muscle_group'] as String,
        isCustom: (map['is_custom'] as int) == 1,
        sortOrder: map['sort_order'] as int,
        createdAt: map['created_at'] as String,
      );
}
