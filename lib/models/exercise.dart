class Exercise {
  final int? id;
  final String nameZh;
  final String? nameEn;
  final String muscleGroup;
  final bool isCustom;

  const Exercise({
    this.id,
    required this.nameZh,
    this.nameEn,
    required this.muscleGroup,
    this.isCustom = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      nameZh: map['name_zh'] as String,
      nameEn: map['name_en'] as String?,
      muscleGroup: map['muscle_group'] as String,
      isCustom: (map['is_custom'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name_zh': nameZh,
      'name_en': nameEn,
      'muscle_group': muscleGroup,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  String localizedName(String locale) {
    if (locale == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameZh;
  }
}
