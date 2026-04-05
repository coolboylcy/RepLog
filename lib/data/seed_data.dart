/// 内置动作库 — 约50个常用动作，覆盖全部肌群，中英文双语
const List<Map<String, dynamic>> kSeedExercises = [
  // ── 胸 chest ──────────────────────────────────────
  {'name_zh': '杠铃卧推', 'name_en': 'Barbell Bench Press', 'muscle_group': 'chest', 'sort_order': 1},
  {'name_zh': '哑铃卧推', 'name_en': 'Dumbbell Bench Press', 'muscle_group': 'chest', 'sort_order': 2},
  {'name_zh': '上斜杠铃卧推', 'name_en': 'Incline Bench Press', 'muscle_group': 'chest', 'sort_order': 3},
  {'name_zh': '上斜哑铃卧推', 'name_en': 'Incline Dumbbell Press', 'muscle_group': 'chest', 'sort_order': 4},
  {'name_zh': '哑铃飞鸟', 'name_en': 'Dumbbell Fly', 'muscle_group': 'chest', 'sort_order': 5},
  {'name_zh': '绳索夹胸', 'name_en': 'Cable Crossover', 'muscle_group': 'chest', 'sort_order': 6},
  {'name_zh': '俯卧撑', 'name_en': 'Push-up', 'muscle_group': 'chest', 'sort_order': 7},

  // ── 背 back ───────────────────────────────────────
  {'name_zh': '硬拉', 'name_en': 'Deadlift', 'muscle_group': 'back', 'sort_order': 1},
  {'name_zh': '引体向上', 'name_en': 'Pull-up', 'muscle_group': 'back', 'sort_order': 2},
  {'name_zh': '高位下拉', 'name_en': 'Lat Pulldown', 'muscle_group': 'back', 'sort_order': 3},
  {'name_zh': '坐姿绳索划船', 'name_en': 'Seated Cable Row', 'muscle_group': 'back', 'sort_order': 4},
  {'name_zh': '杠铃划船', 'name_en': 'Barbell Row', 'muscle_group': 'back', 'sort_order': 5},
  {'name_zh': '哑铃单臂划船', 'name_en': 'Dumbbell Row', 'muscle_group': 'back', 'sort_order': 6},
  {'name_zh': '直臂下压', 'name_en': 'Straight-Arm Pulldown', 'muscle_group': 'back', 'sort_order': 7},

  // ── 肩 shoulders ─────────────────────────────────
  {'name_zh': '杠铃推举', 'name_en': 'Barbell Overhead Press', 'muscle_group': 'shoulders', 'sort_order': 1},
  {'name_zh': '哑铃推举', 'name_en': 'Dumbbell Shoulder Press', 'muscle_group': 'shoulders', 'sort_order': 2},
  {'name_zh': '哑铃侧平举', 'name_en': 'Lateral Raise', 'muscle_group': 'shoulders', 'sort_order': 3},
  {'name_zh': '哑铃前平举', 'name_en': 'Front Raise', 'muscle_group': 'shoulders', 'sort_order': 4},
  {'name_zh': '俯身哑铃飞鸟', 'name_en': 'Bent-Over Lateral Raise', 'muscle_group': 'shoulders', 'sort_order': 5},
  {'name_zh': '阿诺德推举', 'name_en': 'Arnold Press', 'muscle_group': 'shoulders', 'sort_order': 6},
  {'name_zh': '绳索侧平举', 'name_en': 'Cable Lateral Raise', 'muscle_group': 'shoulders', 'sort_order': 7},

  // ── 腿 legs ───────────────────────────────────────
  {'name_zh': '杠铃深蹲', 'name_en': 'Barbell Squat', 'muscle_group': 'legs', 'sort_order': 1},
  {'name_zh': '腿举', 'name_en': 'Leg Press', 'muscle_group': 'legs', 'sort_order': 2},
  {'name_zh': '哑铃弓步', 'name_en': 'Dumbbell Lunge', 'muscle_group': 'legs', 'sort_order': 3},
  {'name_zh': '腿屈伸', 'name_en': 'Leg Extension', 'muscle_group': 'legs', 'sort_order': 4},
  {'name_zh': '腿弯举', 'name_en': 'Leg Curl', 'muscle_group': 'legs', 'sort_order': 5},
  {'name_zh': '罗马尼亚硬拉', 'name_en': 'Romanian Deadlift', 'muscle_group': 'legs', 'sort_order': 6},
  {'name_zh': '站姿提踵', 'name_en': 'Standing Calf Raise', 'muscle_group': 'legs', 'sort_order': 7},
  {'name_zh': '坐姿提踵', 'name_en': 'Seated Calf Raise', 'muscle_group': 'legs', 'sort_order': 8},

  // ── 臂 arms ───────────────────────────────────────
  {'name_zh': '杠铃弯举', 'name_en': 'Barbell Curl', 'muscle_group': 'arms', 'sort_order': 1},
  {'name_zh': '哑铃弯举', 'name_en': 'Dumbbell Curl', 'muscle_group': 'arms', 'sort_order': 2},
  {'name_zh': '锤式弯举', 'name_en': 'Hammer Curl', 'muscle_group': 'arms', 'sort_order': 3},
  {'name_zh': '绳索弯举', 'name_en': 'Cable Curl', 'muscle_group': 'arms', 'sort_order': 4},
  {'name_zh': '双杠臂屈伸', 'name_en': 'Dip', 'muscle_group': 'arms', 'sort_order': 5},
  {'name_zh': '窄握卧推', 'name_en': 'Close-Grip Bench Press', 'muscle_group': 'arms', 'sort_order': 6},
  {'name_zh': '绳索下压', 'name_en': 'Tricep Pushdown', 'muscle_group': 'arms', 'sort_order': 7},
  {'name_zh': '哑铃臂屈伸', 'name_en': 'Skull Crusher', 'muscle_group': 'arms', 'sort_order': 8},

  // ── 核心 core ─────────────────────────────────────
  {'name_zh': '平板支撑', 'name_en': 'Plank', 'muscle_group': 'core', 'sort_order': 1},
  {'name_zh': '卷腹', 'name_en': 'Crunch', 'muscle_group': 'core', 'sort_order': 2},
  {'name_zh': '仰卧举腿', 'name_en': 'Leg Raise', 'muscle_group': 'core', 'sort_order': 3},
  {'name_zh': '俄罗斯转体', 'name_en': 'Russian Twist', 'muscle_group': 'core', 'sort_order': 4},
  {'name_zh': '悬挂举腿', 'name_en': 'Hanging Leg Raise', 'muscle_group': 'core', 'sort_order': 5},
  {'name_zh': '绳索卷腹', 'name_en': 'Cable Crunch', 'muscle_group': 'core', 'sort_order': 6},

  // ── 全身 full_body ────────────────────────────────
  {'name_zh': '杠铃抓举', 'name_en': 'Power Clean', 'muscle_group': 'full_body', 'sort_order': 1},
  {'name_zh': '壶铃摆荡', 'name_en': 'Kettlebell Swing', 'muscle_group': 'full_body', 'sort_order': 2},
  {'name_zh': '波比跳', 'name_en': 'Burpee', 'muscle_group': 'full_body', 'sort_order': 3},
];

/// 内置训练模板
const List<Map<String, dynamic>> kSeedTemplates = [
  // 三分化 Push
  {
    'name_zh': '推 (胸/肩/三头)',
    'name_en': 'Push (Chest/Shoulders/Triceps)',
    'split_type': 'three_day',
    'day_label': 'A',
    'sort_order': 1,
    'is_builtin': 1,
  },
  // 三分化 Pull
  {
    'name_zh': '拉 (背/二头)',
    'name_en': 'Pull (Back/Biceps)',
    'split_type': 'three_day',
    'day_label': 'B',
    'sort_order': 2,
    'is_builtin': 1,
  },
  // 三分化 Legs
  {
    'name_zh': '腿 (腿/核心)',
    'name_en': 'Legs (Legs/Core)',
    'split_type': 'three_day',
    'day_label': 'C',
    'sort_order': 3,
    'is_builtin': 1,
  },
  // 五分化
  {
    'name_zh': '胸日',
    'name_en': 'Chest Day',
    'split_type': 'five_day',
    'day_label': 'A',
    'sort_order': 4,
    'is_builtin': 1,
  },
  {
    'name_zh': '背日',
    'name_en': 'Back Day',
    'split_type': 'five_day',
    'day_label': 'B',
    'sort_order': 5,
    'is_builtin': 1,
  },
  {
    'name_zh': '肩日',
    'name_en': 'Shoulder Day',
    'split_type': 'five_day',
    'day_label': 'C',
    'sort_order': 6,
    'is_builtin': 1,
  },
  {
    'name_zh': '腿日',
    'name_en': 'Leg Day',
    'split_type': 'five_day',
    'day_label': 'D',
    'sort_order': 7,
    'is_builtin': 1,
  },
  {
    'name_zh': '臂日',
    'name_en': 'Arm Day',
    'split_type': 'five_day',
    'day_label': 'E',
    'sort_order': 8,
    'is_builtin': 1,
  },
];
