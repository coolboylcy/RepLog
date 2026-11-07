import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Database get db => _database!;

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'replog.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_zh TEXT NOT NULL,
        name_en TEXT,
        muscle_group TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        template_name TEXT,
        total_sets INTEGER NOT NULL DEFAULT 0,
        total_volume REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        is_warmup INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_zh TEXT NOT NULL,
        name_en TEXT,
        split_type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE template_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        default_sets INTEGER NOT NULL DEFAULT 3,
        default_reps INTEGER NOT NULL DEFAULT 10,
        FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');

    await _seedExercises(db);
    await _seedTemplates(db);
    await _seedTemplateItems(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedTemplateItems(db);
    }
  }

  Future<void> _seedExercises(Database db) async {
    final batch = db.batch();
    for (final exercise in kSeedExercises) {
      batch.insert('exercises', exercise);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedTemplates(Database db) async {
    final batch = db.batch();
    for (final template in kSeedTemplates) {
      batch.insert('templates', template);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedTemplateItems(Database db) async {
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM template_items'));
    if (count != null && count > 0) return;

    final exercises = await db.query('exercises');
    final nameToId = <String, int>{};
    for (final e in exercises) {
      nameToId[e['name_zh'] as String] = e['id'] as int;
    }

    final templates = await db.query('templates');
    final templateNameToId = <String, int>{};
    for (final t in templates) {
      templateNameToId[t['name_zh'] as String] = t['id'] as int;
    }

    final batch = db.batch();
    for (final entry in kSeedTemplateItems.entries) {
      final templateId = templateNameToId[entry.key];
      if (templateId == null) continue;

      for (var i = 0; i < entry.value.length; i++) {
        final item = entry.value[i];
        final exerciseId = nameToId[item['name_zh']];
        if (exerciseId == null) continue;

        batch.insert('template_items', {
          'template_id': templateId,
          'exercise_id': exerciseId,
          'sort_order': i,
          'default_sets': item['sets'] ?? 3,
          'default_reps': item['reps'] ?? 10,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> init() async {
    _database = await _initDatabase();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
