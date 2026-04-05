import '../data/database_helper.dart';
import '../models/template.dart';
import '../models/template_item.dart';

class TemplateRepository {
  final DatabaseHelper _db;

  TemplateRepository(this._db);

  Future<List<Template>> getAll() async {
    final rows = await _db.db.query('templates', orderBy: 'sort_order');
    return rows.map(Template.fromMap).toList();
  }

  Future<List<Template>> getBySplitType(String splitType) async {
    final rows = await _db.db.query(
      'templates',
      where: 'split_type = ?',
      whereArgs: [splitType],
      orderBy: 'sort_order',
    );
    return rows.map(Template.fromMap).toList();
  }

  Future<List<TemplateItem>> getItemsForTemplate(int templateId) async {
    final rows = await _db.db.query(
      'template_items',
      where: 'template_id = ?',
      whereArgs: [templateId],
      orderBy: 'sort_order',
    );
    return rows.map(TemplateItem.fromMap).toList();
  }

  Future<Template> insertTemplate(Template template) async {
    final now = DateTime.now().toIso8601String();
    final map = template.toMap()..['created_at'] = now;
    final id = await _db.db.insert('templates', map);
    return Template.fromMap({...map, 'id': id});
  }

  Future<void> deleteTemplate(int id) async {
    await _db.db.delete('templates', where: 'id = ? AND is_builtin = 0', whereArgs: [id]);
  }
}
