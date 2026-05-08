import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static const _dbName = 'replog.db';
  static const _dbVersion = 2;

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Database get db {
    assert(_db != null, 'DatabaseHelper.init() must be called before use');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedTemplateItems(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE exercises (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name_zh      TEXT    NOT NULL,
        name_en      TEXT    NOT NULL,
        muscle_group TEXT    NOT NULL,
        is_custom    INTEGER NOT NULL DEFAULT 0,
        sort_order   INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_exercises_muscle ON exercises(muscle_group)');

    await db.execute('''
      CREATE TABLE workouts (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at       TEXT    NOT NULL,
        ended_at         TEXT,
        muscle_groups    TEXT    NOT NULL DEFAULT '',
        notes            TEXT,
        duration_seconds INTEGER,
        total_sets       INTEGER NOT NULL DEFAULT 0,
        total_volume     REAL    NOT NULL DEFAULT 0.0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_workouts_started ON workouts(started_at DESC)');

    await db.execute('''
      CREATE TABLE workout_sets (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id    INTEGER NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
        exercise_id   INTEGER NOT NULL REFERENCES exercises(id),
        exercise_name TEXT    NOT NULL,
        muscle_group  TEXT    NOT NULL,
        weight        REAL    NOT NULL,
        reps          INTEGER NOT NULL,
        set_order     INTEGER NOT NULL,
        notes         TEXT,
        created_at    TEXT    NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sets_workout ON workout_sets(workout_id, set_order)');
    await db.execute(
        'CREATE INDEX idx_sets_exercise ON workout_sets(exercise_id)');

    await db.execute('''
      CREATE TABLE templates (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name_zh    TEXT    NOT NULL,
        name_en    TEXT    NOT NULL,
        split_type TEXT    NOT NULL,
        day_label  TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_builtin INTEGER NOT NULL DEFAULT 1,
        created_at TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE template_items (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id  INTEGER NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
        exercise_id  INTEGER NOT NULL REFERENCES exercises(id),
        default_sets INTEGER NOT NULL DEFAULT 3,
        default_reps INTEGER NOT NULL DEFAULT 10,
        sort_order   INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_template_items ON template_items(template_id, sort_order)');
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final e in kSeedExercises) {
      batch.insert('exercises', {
        ...e,
        'is_custom': 0,
        'created_at': now,
      });
    }

    for (final t in kSeedTemplates) {
      batch.insert('templates', {
        ...t,
        'created_at': now,
      });
    }

    await batch.commit(noResult: true);
    await _seedTemplateItems(db);
  }

  Future<void> _seedTemplateItems(Database db) async {
    final existing = await db.rawQuery('SELECT COUNT(*) AS c FROM template_items');
    if ((existing.first['c'] as int) > 0) return;

    final exerciseRows = await db.query('exercises', columns: ['id', 'name_zh']);
    final exerciseIds = {
      for (final r in exerciseRows) r['name_zh'] as String: r['id'] as int
    };

    final templateRows = await db.query('templates', columns: ['id', 'name_zh']);
    final templateIds = {
      for (final r in templateRows) r['name_zh'] as String: r['id'] as int
    };

    final batch = db.batch();
    for (final entry in kSeedTemplateItems.entries) {
      final templateId = templateIds[entry.key];
      if (templateId == null) continue;
      for (int i = 0; i < entry.value.length; i++) {
        final item = entry.value[i];
        final exerciseId = exerciseIds[item['name'] as String];
        if (exerciseId == null) continue;
        batch.insert('template_items', {
          'template_id': templateId,
          'exercise_id': exerciseId,
          'default_sets': item['sets'] as int,
          'default_reps': item['reps'] as int,
          'sort_order': i,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
