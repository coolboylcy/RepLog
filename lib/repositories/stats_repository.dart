import '../data/database_helper.dart';

class StatsRepository {
  final DatabaseHelper _db;

  StatsRepository(this._db);

  Future<int> getTotalDays() async {
    final result = await _db.db.rawQuery('''
      SELECT COUNT(DISTINCT DATE(started_at)) AS days
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return (result.first['days'] as int?) ?? 0;
  }

  Future<int> getTotalSets() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_sets), 0) AS total
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  Future<double> getTotalVolume() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(total_volume), 0) AS volume
      FROM workouts
      WHERE ended_at IS NOT NULL
    ''');
    return ((result.first['volume'] as num?) ?? 0).toDouble();
  }

  /// 返回最近 N 天中哪些天有训练（true = 有训练，false = 无训练）
  Future<List<bool>> getRecentActivity({int days = 7}) async {
    final now = DateTime.now();
    final result = await _db.db.rawQuery('''
      SELECT DISTINCT DATE(started_at) AS training_date
      FROM workouts
      WHERE ended_at IS NOT NULL
        AND DATE(started_at) >= DATE(?, '-${days - 1} days')
      ORDER BY training_date ASC
    ''', [now.toIso8601String()]);

    final trainingDates = result.map((r) => r['training_date'] as String).toSet();

    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return trainingDates.contains(dateStr);
    });
  }

  /// 计算连续有训练的周数（每周至少1次）
  Future<int> getCurrentStreak() async {
    final result = await _db.db.rawQuery('''
      SELECT DISTINCT strftime('%Y-%W', started_at) AS week
      FROM workouts
      WHERE ended_at IS NOT NULL
      ORDER BY week DESC
    ''');

    if (result.isEmpty) return 0;

    final now = DateTime.now();
    final currentWeek =
        '${now.year}-${_weekNumber(now).toString().padLeft(2, '0')}';
    final weeks = result.map((r) => r['week'] as String).toList();

    // 如果当前周或上周没有训练，streak 从0开始
    if (weeks.first != currentWeek) {
      final lastWeek = _weekStringOffset(now, -1);
      if (weeks.first != lastWeek) return 0;
    }

    int streak = 1;
    for (int i = 0; i < weeks.length - 1; i++) {
      final current = _parseWeek(weeks[i]);
      final prev = _parseWeek(weeks[i + 1]);
      final diff = current.difference(prev).inDays;
      if (diff >= 6 && diff <= 8) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _weekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final diff = date.difference(startOfYear).inDays;
    return ((diff + startOfYear.weekday - 1) / 7).floor() + 1;
  }

  String _weekStringOffset(DateTime date, int weekOffset) {
    final offset = date.subtract(Duration(days: -weekOffset * 7));
    return '${offset.year}-${_weekNumber(offset).toString().padLeft(2, '0')}';
  }

  DateTime _parseWeek(String yearWeek) {
    final parts = yearWeek.split('-');
    final year = int.parse(parts[0]);
    final week = int.parse(parts[1]);
    final jan1 = DateTime(year, 1, 1);
    return jan1.add(Duration(days: (week - 1) * 7));
  }
}
