const List<Map<String, dynamic>> kSeedExercises = [
  // 胸 (Chest)
  {'name_zh': '杠铃卧推', 'name_en': 'Barbell Bench Press', 'muscle_group': 'chest', 'is_custom': 0},
  {'name_zh': '哑铃卧推', 'name_en': 'Dumbbell Bench Press', 'muscle_group': 'chest', 'is_custom': 0},
  {'name_zh': '上斜杠铃卧推', 'name_en': 'Incline Barbell Bench Press', 'muscle_group': 'chest', 'is_custom': 0},
  {'name_zh': '上斜哑铃卧推', 'name_en': 'Incline Dumbbell Bench Press', 'muscle_group': 'chest', 'is_custom': 0},
  {'name_zh': '龙门架夹胸', 'name_en': 'Cable Fly', 'muscle_group': 'chest', 'is_custom': 0},
  {'name_zh': '蝴蝶机夹胸', 'name_en': 'Pec Deck Fly', 'muscle_group': 'chest', 'is_custom': 0},

  // 背 (Back)
  {'name_zh': '引体向上', 'name_en': 'Pull Up', 'muscle_group': 'back', 'is_custom': 0},
  {'name_zh': '高位下拉', 'name_en': 'Lat Pulldown', 'muscle_group': 'back', 'is_custom': 0},
  {'name_zh': '杠铃划船', 'name_en': 'Barbell Row', 'muscle_group': 'back', 'is_custom': 0},
  {'name_zh': '哑铃划船', 'name_en': 'Dumbbell Row', 'muscle_group': 'back', 'is_custom': 0},
  {'name_zh': '坐姿划船', 'name_en': 'Seated Cable Row', 'muscle_group': 'back', 'is_custom': 0},
  {'name_zh': '硬拉', 'name_en': 'Deadlift', 'muscle_group': 'back', 'is_custom': 0},

  // 肩 (Shoulders)
  {'name_zh': '杠铃推举', 'name_en': 'Overhead Press', 'muscle_group': 'shoulders', 'is_custom': 0},
  {'name_zh': '哑铃推举', 'name_en': 'Dumbbell Shoulder Press', 'muscle_group': 'shoulders', 'is_custom': 0},
  {'name_zh': '哑铃侧平举', 'name_en': 'Lateral Raise', 'muscle_group': 'shoulders', 'is_custom': 0},
  {'name_zh': '哑铃前平举', 'name_en': 'Front Raise', 'muscle_group': 'shoulders', 'is_custom': 0},
  {'name_zh': '反向飞鸟', 'name_en': 'Reverse Fly', 'muscle_group': 'shoulders', 'is_custom': 0},
  {'name_zh': '面拉', 'name_en': 'Face Pull', 'muscle_group': 'shoulders', 'is_custom': 0},

  // 腿 (Legs)
  {'name_zh': '杠铃深蹲', 'name_en': 'Barbell Squat', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '腿举', 'name_en': 'Leg Press', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '罗马尼亚硬拉', 'name_en': 'Romanian Deadlift', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '腿弯举', 'name_en': 'Leg Curl', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '腿屈伸', 'name_en': 'Leg Extension', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '小腿提踵', 'name_en': 'Calf Raise', 'muscle_group': 'legs', 'is_custom': 0},
  {'name_zh': '保加利亚分腿蹲', 'name_en': 'Bulgarian Split Squat', 'muscle_group': 'legs', 'is_custom': 0},

  // 手臂 (Arms)
  {'name_zh': '杠铃弯举', 'name_en': 'Barbell Curl', 'muscle_group': 'arms', 'is_custom': 0},
  {'name_zh': '哑铃弯举', 'name_en': 'Dumbbell Curl', 'muscle_group': 'arms', 'is_custom': 0},
  {'name_zh': '锤式弯举', 'name_en': 'Hammer Curl', 'muscle_group': 'arms', 'is_custom': 0},
  {'name_zh': '三头绳索下压', 'name_en': 'Tricep Pushdown', 'muscle_group': 'arms', 'is_custom': 0},
  {'name_zh': '头顶三头臂屈伸', 'name_en': 'Overhead Tricep Extension', 'muscle_group': 'arms', 'is_custom': 0},
  {'name_zh': '窄距卧推', 'name_en': 'Close Grip Bench Press', 'muscle_group': 'arms', 'is_custom': 0},

  // 核心 (Core)
  {'name_zh': '卷腹', 'name_en': 'Crunch', 'muscle_group': 'core', 'is_custom': 0},
  {'name_zh': '悬垂举腿', 'name_en': 'Hanging Leg Raise', 'muscle_group': 'core', 'is_custom': 0},
  {'name_zh': '平板支撑', 'name_en': 'Plank', 'muscle_group': 'core', 'is_custom': 0},
  {'name_zh': '俄罗斯转体', 'name_en': 'Russian Twist', 'muscle_group': 'core', 'is_custom': 0},
];

const List<Map<String, dynamic>> kSeedTemplates = [
  // PPL 3-day split
  {'name_zh': '推（胸肩三头）', 'name_en': 'Push (Chest/Shoulders/Triceps)', 'split_type': 'three_day'},
  {'name_zh': '拉（背二头）', 'name_en': 'Pull (Back/Biceps)', 'split_type': 'three_day'},
  {'name_zh': '腿（股四头/腘绳/小腿）', 'name_en': 'Legs (Quads/Hamstrings/Calves)', 'split_type': 'three_day'},

  // 5-day split
  {'name_zh': '胸部训练', 'name_en': 'Chest Day', 'split_type': 'five_day'},
  {'name_zh': '背部训练', 'name_en': 'Back Day', 'split_type': 'five_day'},
  {'name_zh': '肩部训练', 'name_en': 'Shoulder Day', 'split_type': 'five_day'},
  {'name_zh': '腿部训练', 'name_en': 'Leg Day', 'split_type': 'five_day'},
  {'name_zh': '手臂训练', 'name_en': 'Arm Day', 'split_type': 'five_day'},
];

const Map<String, List<Map<String, dynamic>>> kSeedTemplateItems = {
  '推（胸肩三头）': [
    {'name_zh': '杠铃卧推', 'sets': 4, 'reps': 8},
    {'name_zh': '上斜哑铃卧推', 'sets': 3, 'reps': 10},
    {'name_zh': '龙门架夹胸', 'sets': 3, 'reps': 12},
    {'name_zh': '杠铃推举', 'sets': 3, 'reps': 8},
    {'name_zh': '哑铃侧平举', 'sets': 3, 'reps': 15},
  ],
  '拉（背二头）': [
    {'name_zh': '硬拉', 'sets': 4, 'reps': 6},
    {'name_zh': '引体向上', 'sets': 3, 'reps': 8},
    {'name_zh': '杠铃划船', 'sets': 3, 'reps': 10},
    {'name_zh': '坐姿划船', 'sets': 3, 'reps': 12},
    {'name_zh': '杠铃弯举', 'sets': 3, 'reps': 10},
  ],
  '腿（股四头/腘绳/小腿）': [
    {'name_zh': '杠铃深蹲', 'sets': 4, 'reps': 8},
    {'name_zh': '腿举', 'sets': 3, 'reps': 12},
    {'name_zh': '罗马尼亚硬拉', 'sets': 3, 'reps': 10},
    {'name_zh': '腿弯举', 'sets': 3, 'reps': 12},
    {'name_zh': '小腿提踵', 'sets': 4, 'reps': 15},
  ],
  '胸部训练': [
    {'name_zh': '杠铃卧推', 'sets': 4, 'reps': 8},
    {'name_zh': '上斜杠铃卧推', 'sets': 3, 'reps': 10},
    {'name_zh': '哑铃卧推', 'sets': 3, 'reps': 10},
    {'name_zh': '龙门架夹胸', 'sets': 3, 'reps': 12},
    {'name_zh': '蝴蝶机夹胸', 'sets': 3, 'reps': 12},
  ],
  '背部训练': [
    {'name_zh': '引体向上', 'sets': 4, 'reps': 8},
    {'name_zh': '杠铃划船', 'sets': 4, 'reps': 8},
    {'name_zh': '高位下拉', 'sets': 3, 'reps': 10},
    {'name_zh': '坐姿划船', 'sets': 3, 'reps': 12},
    {'name_zh': '哑铃划船', 'sets': 3, 'reps': 10},
  ],
  '肩部训练': [
    {'name_zh': '杠铃推举', 'sets': 4, 'reps': 8},
    {'name_zh': '哑铃推举', 'sets': 3, 'reps': 10},
    {'name_zh': '哑铃侧平举', 'sets': 4, 'reps': 15},
    {'name_zh': '反向飞鸟', 'sets': 3, 'reps': 12},
    {'name_zh': '面拉', 'sets': 3, 'reps': 15},
  ],
  '腿部训练': [
    {'name_zh': '杠铃深蹲', 'sets': 4, 'reps': 8},
    {'name_zh': '腿举', 'sets': 4, 'reps': 12},
    {'name_zh': '罗马尼亚硬拉', 'sets': 3, 'reps': 10},
    {'name_zh': '腿屈伸', 'sets': 3, 'reps': 12},
    {'name_zh': '保加利亚分腿蹲', 'sets': 3, 'reps': 10},
  ],
  '手臂训练': [
    {'name_zh': '杠铃弯举', 'sets': 4, 'reps': 10},
    {'name_zh': '锤式弯举', 'sets': 3, 'reps': 10},
    {'name_zh': '三头绳索下压', 'sets': 4, 'reps': 12},
    {'name_zh': '头顶三头臂屈伸', 'sets': 3, 'reps': 10},
    {'name_zh': '窄距卧推', 'sets': 3, 'reps': 8},
  ],
};
