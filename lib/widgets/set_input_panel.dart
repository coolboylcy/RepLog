import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_set.dart';

class SetInputPanel extends StatefulWidget {
  final WorkoutSet? lastSet;
  final bool isKg;
  final ValueChanged<({double weight, int reps})> onAdd;

  const SetInputPanel({
    super.key,
    this.lastSet,
    this.isKg = true,
    required this.onAdd,
  });

  @override
  State<SetInputPanel> createState() => _SetInputPanelState();
}

class _SetInputPanelState extends State<SetInputPanel> {
  late double _weight;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _weight = widget.lastSet?.weight ?? 20.0;
    _reps = widget.lastSet?.reps ?? 10;
  }

  @override
  void didUpdateWidget(SetInputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastSet != oldWidget.lastSet) {
      setState(() {
        _weight = widget.lastSet?.weight ?? 20.0;
        _reps = widget.lastSet?.reps ?? 10;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = widget.isKg ? 'kg' : 'lb';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('重量 ($unit)',
                        style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => setState(() {
                            _weight = (_weight - 2.5).clamp(0, 999);
                          }),
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            _weight % 1 == 0
                                ? _weight.toInt().toString()
                                : _weight.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => setState(() {
                            _weight = (_weight + 2.5).clamp(0, 999);
                          }),
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('次数', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => setState(() {
                            _reps = (_reps - 1).clamp(1, 100);
                          }),
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '$_reps',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => setState(() {
                            _reps = (_reps + 1).clamp(1, 100);
                          }),
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onAdd((weight: _weight, reps: _reps));
              },
              icon: const Icon(Icons.add),
              label: const Text('添加组'),
            ),
          ),
        ],
      ),
    );
  }
}
