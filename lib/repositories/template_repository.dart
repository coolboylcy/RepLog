import '../data/database_helper.dart';
import '../models/template.dart';
import '../models/template_item.dart';

class TemplateRepository {
  final DatabaseHelper _db;

  TemplateRepository(this._db);

  Future<List<Template>> getAllTemplates() async {
    final maps = await _db.db.query('templates', orderBy: 'split_type, id');
    return maps.map(Template.fromMap).toList();
  }

  Future<List<Template>> getTemplatesBySplitType(String splitType) async {
    final maps = await _db.db.query(
      'templates',
      where: 'split_type = ?',
      whereArgs: [splitType],
      orderBy: 'id',
    );
    return maps.map(Template.fromMap).toList();
  }

  Future<Template?> getTemplateById(int id) async {
    final maps = await _db.db.query(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Template.fromMap(maps.first);
  }

  Future<List<TemplateItem>> getTemplateItems(int templateId) async {
    final maps = await _db.db.rawQuery('''
      SELECT ti.*, e.name_zh, e.name_en, e.muscle_group
      FROM template_items ti
      JOIN exercises e ON ti.exercise_id = e.id
      WHERE ti.template_id = ?
      ORDER BY ti.sort_order
    ''', [templateId]);
    return maps.map(TemplateItem.fromMap).toList();
  }
}
