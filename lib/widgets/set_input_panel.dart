import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/workout_set.dart';
import '../theme/app_colors.dart';

class SetInputPanel extends StatefulWidget {
  final WorkoutSet? lastSet;
  final bool isKg;
  final VoidCallback onLogSet;
  final void Function(double weight, int reps) onValuesChanged;

  const SetInputPanel({
    super.key,
    this.lastSet,
    this.isKg = true,
    required this.onLogSet,
    required this.onValuesChanged,
  });

  @override
  State<SetInputPanel> createState() => SetInputPanelState();
}

class SetInputPanelState extends State<SetInputPanel> {
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

  void _setWeight(double value) {
    if (value < 0) return;
    setState(() => _weight = value);
    widget.onValuesChanged(_weight, _reps);
  }

  void _setReps(int value) {
    if (value < 1) return;
    setState(() => _reps = value);
    widget.onValuesChanged(_weight, _reps);
  }

  double get weight => _weight;
  int get reps => _reps;

  String get _weightDisplay {
    if (_weight == _weight.truncate()) {
      return _weight.toInt().toString();
    }
    return _weight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = widget.isKg ? l10n.kg : l10n.lb;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.lastSet != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '上次: ${widget.lastSet!.weight % 1 == 0 ? widget.lastSet!.weight.toInt() : widget.lastSet!.weight}$unit × ${widget.lastSet!.reps}',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _InputStepper(
                  label: '${l10n.weight} ($unit)',
                  display: _weightDisplay,
                  onDecrease: () => _setWeight(_weight - 2.5),
                  onIncrease: () => _setWeight(_weight + 2.5),
                  onTap: () => _showWeightDialog(context),
                  smallDecrease: () => _setWeight(_weight - 1.25),
                  smallIncrease: () => _setWeight(_weight + 1.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InputStepper(
                  label: l10n.reps,
                  display: _reps.toString(),
                  onDecrease: () => _setReps(_reps - 1),
                  onIncrease: () => _setReps(_reps + 1),
                  onTap: () => _showRepsDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onLogSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.logSet,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeightDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _weightDisplay);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.weight),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
          ],
          decoration:
              InputDecoration(suffix: Text(widget.isKg ? l10n.kg : l10n.lb)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) _setWeight(val);
              Navigator.pop(ctx);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _showRepsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _reps.toString());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reps),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0) _setReps(val);
              Navigator.pop(ctx);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _InputStepper extends StatelessWidget {
  final String label;
  final String display;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onTap;
  final VoidCallback? smallDecrease;
  final VoidCallback? smallIncrease;

  const _InputStepper({
    required this.label,
    required this.display,
    required this.onDecrease,
    required this.onIncrease,
    required this.onTap,
    this.smallDecrease,
    this.smallIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _StepButton(icon: Icons.remove, onTap: onDecrease),
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Center(
                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              _StepButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
        ),
        if (smallDecrease != null && smallIncrease != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: smallDecrease,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('-1.25', style: TextStyle(fontSize: 11)),
                ),
                TextButton(
                  onPressed: smallIncrease,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('+1.25', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(icon, size: 22, color: AppColors.primary),
      ),
    );
  }
}
