import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../app/service_locator.dart';
import '../theme/app_colors.dart';

class ExerciseHistoryPage extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseHistoryPage({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  Map<String, double> _pr = {'max_weight': 0, 'max_volume': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final statsRepo = ServiceLocator.of(context).statsRepository;
    final history = await statsRepo.getExerciseHistory(widget.exerciseId);
    final pr = await statsRepo.getExercisePR(widget.exerciseId);
    if (mounted) {
      setState(() {
        _history = history;
        _pr = pr;
        _loading = false;
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final row in _history) {
      final date = (row['started_at'] as String).substring(0, 10);
      map.putIfAbsent(date, () => []).add(row);
    }
    return map;
  }

  List<double> get _maxWeightPerSession {
    return _grouped.values
        .map((sets) => sets.fold<double>(
            0,
            (max, s) =>
                (s['weight'] as double) > max ? s['weight'] as double : max))
        .toList()
        .reversed
        .take(10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final grouped = _grouped;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Text(l10n.noHistory,
                      style: const TextStyle(color: AppColors.textHint)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PrCard(pr: _pr, l10n: l10n),
                      const SizedBox(height: 20),
                      if (_maxWeightPerSession.length > 1) ...[
                        Text(l10n.maxWeight,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: CustomPaint(
                            painter:
                                _LineChartPainter(values: _maxWeightPerSession),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(l10n.exerciseHistory,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      ...grouped.entries.map((entry) {
                        final date = DateTime.parse(entry.key);
                        final dateStr = DateFormat(
                          locale.startsWith('zh')
                              ? 'yyyy年MM月dd日'
                              : 'MMMM d, yyyy',
                          locale.startsWith('zh') ? 'zh_CN' : 'en_US',
                        ).format(date);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(dateStr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ),
                            ...entry.value.asMap().entries.map((e) {
                              final s = e.value;
                              final w = (s['weight'] as double);
                              final r = s['reps'] as int;
                              final weightStr = w % 1 == 0
                                  ? w.toInt().toString()
                                  : w.toStringAsFixed(1);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${e.key + 1}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('$weightStr kg × $r',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 16),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}

class _PrCard extends StatelessWidget {
  final Map<String, double> pr;
  final AppLocalizations l10n;

  const _PrCard({required this.pr, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final maxW = pr['max_weight']!;
    final maxV = pr['max_volume']!;
    final maxWStr =
        maxW % 1 == 0 ? maxW.toInt().toString() : maxW.toStringAsFixed(1);
    final maxVStr =
        maxV % 1 == 0 ? maxV.toInt().toString() : maxV.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.personalRecord,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '${l10n.maxWeight}: $maxWStr kg  |  ${l10n.maxVolumeSingle}: $maxVStr kg',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final path = Path();
    final stepX = size.width / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y =
          size.height - ((values[i] - minVal) / range) * (size.height - 16) - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.values != values;
}
