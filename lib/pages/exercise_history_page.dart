import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_provider.dart';

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
  Map<String, dynamic>? _pr;
  List<Map<String, dynamic>> _history = [];
  bool _isKg = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = ServiceProvider.of(context);
    final prefs = await SharedPreferences.getInstance();
    final pr = await sp.statsRepository.getExercisePR(widget.exerciseId);
    final history =
        await sp.statsRepository.getExerciseHistory(widget.exerciseId);
    final isKg = prefs.getString('weight_unit') != 'lb';
    if (mounted) {
      setState(() {
        _pr = pr;
        _history = history;
        _isKg = isKg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unit = _isKg ? 'kg' : 'lb';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_pr != null) ...[
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(l10n.personalRecord,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(l10n.maxWeight,
                                style: theme.textTheme.labelMedium),
                            const SizedBox(height: 4),
                            Text(
                              '${(_isKg ? _pr!['max_weight'] : _pr!['max_weight'] * 2.20462).toStringAsFixed(1)} $unit',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(l10n.maxVolume,
                                style: theme.textTheme.labelMedium),
                            const SizedBox(height: 4),
                            Text(
                              '${(_isKg ? _pr!['max_volume'] : _pr!['max_volume'] * 2.20462).toStringAsFixed(0)} $unit',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_history.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _WeightChartPainter(
                  data: _history,
                  isKg: _isKg,
                  lineColor: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.exerciseHistory,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._history.map((row) {
              final w = _isKg
                  ? (row['weight'] as num).toDouble()
                  : (row['weight'] as num).toDouble() * 2.20462;
              final reps = row['reps'] as int;
              final date = row['date'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(date,
                          style: theme.textTheme.bodySmall),
                    ),
                    Text('${w.toStringAsFixed(1)} $unit × $reps'),
                    const Spacer(),
                    Text(
                      '${(w * reps).toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.noHistory,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool isKg;
  final Color lineColor;
  final Color textColor;

  _WeightChartPainter({
    required this.data,
    required this.isKg,
    required this.lineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final weights = data
        .map((d) => (d['weight'] as num).toDouble() * (isKg ? 1 : 2.20462))
        .toList();
    final maxW = weights.reduce(max);
    final minW = weights.reduce(min);
    final range = maxW - minW;
    final effectiveRange = range == 0 ? 1.0 : range;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    for (var i = 0; i < weights.length; i++) {
      final x = padding + (i / max(1, weights.length - 1)) * chartWidth;
      final y = padding +
          chartHeight -
          ((weights[i] - minW) / effectiveRange) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    canvas.drawPath(path, paint);

    final textStyle = TextStyle(color: textColor.withOpacity(0.6), fontSize: 10);
    final maxLabel = TextPainter(
      text: TextSpan(text: maxW.toStringAsFixed(1), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    maxLabel.paint(canvas, Offset(0, padding - 6));

    final minLabel = TextPainter(
      text: TextSpan(text: minW.toStringAsFixed(1), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    minLabel.paint(canvas, Offset(0, padding + chartHeight - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
