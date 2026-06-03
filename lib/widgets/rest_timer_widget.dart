import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// 休息计时器组件
/// 用法：在 workout_service.dart 中存储开始时间戳，此组件负责显示
class RestTimerWidget extends StatefulWidget {
  final VoidCallback? onDismiss;

  const RestTimerWidget({super.key, this.onDismiss});

  @override
  State<RestTimerWidget> createState() => RestTimerWidgetState();
}

class RestTimerWidgetState extends State<RestTimerWidget>
    with WidgetsBindingObserver {
  static const _defaultDuration = 90;
  static const _presets = [60, 90, 120, 180];

  int _totalSeconds = _defaultDuration;
  int _remainingSeconds = _defaultDuration;
  DateTime? _startedAt;
  Timer? _timer;
  bool _isRunning = false;
  bool _isDone = false;

  void start({int? seconds}) {
    final duration = seconds ?? _defaultDuration;
    setState(() {
      _totalSeconds = duration;
      _remainingSeconds = duration;
      _startedAt = DateTime.now();
      _isRunning = true;
      _isDone = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt == null) return;
      final elapsed = DateTime.now().difference(_startedAt!).inSeconds;
      final remaining = (_totalSeconds - elapsed).clamp(0, _totalSeconds);
      setState(() {
        _remainingSeconds = remaining;
        if (remaining == 0) {
          _isRunning = false;
          _isDone = true;
          _timer?.cancel();
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _isRunning &&
        _startedAt != null) {
      // 重新计算剩余时间（防止后台暂停计时器）
      final elapsed = DateTime.now().difference(_startedAt!).inSeconds;
      final remaining = (_totalSeconds - elapsed).clamp(0, _totalSeconds);
      setState(() {
        _remainingSeconds = remaining;
        if (remaining == 0) {
          _isRunning = false;
          _isDone = true;
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_isRunning && !_isDone) return const SizedBox.shrink();

    final progress =
        _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _isDone
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDone ? AppColors.success : AppColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 圆形进度
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _isDone ? 1.0 : progress,
                  backgroundColor: Colors.grey[200],
                  color: _isDone ? AppColors.success : AppColors.primary,
                  strokeWidth: 3,
                ),
                Text(
                  _isDone ? '✓' : _timeLabel.substring(_timeLabel.length - 2),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isDone ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isDone
                      ? l10n.restTimerDone
                      : '${l10n.restTimer}  $_timeLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _isDone ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                // 预设选项
                if (!_isDone)
                  Row(
                    children: _presets.map((sec) {
                      final label = sec >= 60 ? '${sec ~/ 60}min' : '${sec}s';
                      return Padding(
                        padding: const EdgeInsets.only(right: 6, top: 4),
                        child: InkWell(
                          onTap: () => start(seconds: sec),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _timer?.cancel();
              setState(() {
                _isRunning = false;
                _isDone = false;
              });
              widget.onDismiss?.call();
            },
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
