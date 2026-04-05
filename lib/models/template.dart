class Template {
  final int? id;
  final String nameZh;
  final String nameEn;
  final String splitType; // three_day / five_day / custom
  final String? dayLabel;
  final int sortOrder;
  final bool isBuiltin;
  final String createdAt;

  const Template({
    this.id,
    required this.nameZh,
    required this.nameEn,
    required this.splitType,
    this.dayLabel,
    this.sortOrder = 0,
    this.isBuiltin = true,
    required this.createdAt,
  });

  String localizedName(String locale) =>
      locale.startsWith('zh') ? nameZh : nameEn;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name_zh': nameZh,
        'name_en': nameEn,
        'split_type': splitType,
        'day_label': dayLabel,
        'sort_order': sortOrder,
        'is_builtin': isBuiltin ? 1 : 0,
        'created_at': createdAt,
      };

  factory Template.fromMap(Map<String, dynamic> map) => Template(
        id: map['id'] as int?,
        nameZh: map['name_zh'] as String,
        nameEn: map['name_en'] as String,
        splitType: map['split_type'] as String,
        dayLabel: map['day_label'] as String?,
        sortOrder: map['sort_order'] as int,
        isBuiltin: (map['is_builtin'] as int) == 1,
        createdAt: map['created_at'] as String,
      );
}
