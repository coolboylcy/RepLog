class Template {
  final int? id;
  final String nameZh;
  final String? nameEn;
  final String splitType;

  const Template({
    this.id,
    required this.nameZh,
    this.nameEn,
    required this.splitType,
  });

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id'] as int?,
      nameZh: map['name_zh'] as String,
      nameEn: map['name_en'] as String?,
      splitType: map['split_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name_zh': nameZh,
      'name_en': nameEn,
      'split_type': splitType,
    };
  }

  String localizedName(String locale) {
    if (locale == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameZh;
  }
}
