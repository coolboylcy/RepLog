import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExerciseDemoLoop extends StatefulWidget {
  final String muscleGroup;
  final double size;

  const ExerciseDemoLoop({
    super.key,
    required this.muscleGroup,
    this.size = 56,
  });

  @override
  State<ExerciseDemoLoop> createState() => _ExerciseDemoLoopState();
}

class _ExerciseDemoLoopState extends State<ExerciseDemoLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.forMuscleGroup(widget.muscleGroup)
              .withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ExerciseDemoPainter(
              progress: Curves.easeInOut.transform(_controller.value),
              color: AppColors.forMuscleGroup(widget.muscleGroup),
              muscleGroup: widget.muscleGroup,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseDemoPainter extends CustomPainter {
  final double progress;
  final Color color;
  final String muscleGroup;

  _ExerciseDemoPainter({
    required this.progress,
    required this.color,
    required this.muscleGroup,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final light = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final c = Offset(size.width / 2, size.height * 0.48);
    canvas.drawCircle(
        Offset(c.dx, size.height * 0.22), size.width * 0.08, fill);
    canvas.drawLine(Offset(c.dx, size.height * 0.31),
        Offset(c.dx, size.height * 0.58), stroke);

    final phase = (progress - 0.5) * 2;
    switch (muscleGroup) {
      case 'legs':
        final knee = size.height * (0.72 - progress * 0.10);
        canvas.drawLine(Offset(c.dx - 5, size.height * 0.58),
            Offset(c.dx - 18, knee), stroke);
        canvas.drawLine(Offset(c.dx + 5, size.height * 0.58),
            Offset(c.dx + 18, knee), stroke);
        canvas.drawLine(Offset(c.dx - 18, knee),
            Offset(c.dx - 22, size.height * 0.90), light);
        canvas.drawLine(Offset(c.dx + 18, knee),
            Offset(c.dx + 22, size.height * 0.90), light);
        break;
      case 'back':
        canvas.drawArc(
          Rect.fromCenter(
              center: c, width: size.width * 0.62, height: size.height * 0.46),
          math.pi * (0.12 + progress * 0.18),
          math.pi * 0.75,
          false,
          stroke,
        );
        canvas.drawArc(
          Rect.fromCenter(
              center: c, width: size.width * 0.62, height: size.height * 0.46),
          math.pi * (0.88 - progress * 0.18),
          -math.pi * 0.75,
          false,
          stroke,
        );
        break;
      case 'arms':
        canvas.drawLine(Offset(c.dx - 7, size.height * 0.38),
            Offset(c.dx - 23, size.height * (0.58 - progress * 0.20)), stroke);
        canvas.drawLine(Offset(c.dx + 7, size.height * 0.38),
            Offset(c.dx + 23, size.height * (0.58 - progress * 0.20)), stroke);
        canvas.drawCircle(
            Offset(c.dx - 23, size.height * (0.58 - progress * 0.20)), 3, fill);
        canvas.drawCircle(
            Offset(c.dx + 23, size.height * (0.58 - progress * 0.20)), 3, fill);
        break;
      case 'core':
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(c.dx, size.height * 0.60),
              width: size.width * 0.50,
              height: size.height * 0.28),
          math.pi * (1.15 + progress * 0.20),
          math.pi * 0.70,
          false,
          stroke,
        );
        break;
      default:
        canvas.drawLine(Offset(c.dx - 6, size.height * 0.38),
            Offset(c.dx - 23, size.height * (0.38 + phase * 0.08)), stroke);
        canvas.drawLine(Offset(c.dx + 6, size.height * 0.38),
            Offset(c.dx + 23, size.height * (0.38 + phase * 0.08)), stroke);
        canvas.drawLine(Offset(c.dx - 24, size.height * (0.34 + phase * 0.08)),
            Offset(c.dx + 24, size.height * (0.34 + phase * 0.08)), light);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseDemoPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.muscleGroup != muscleGroup;
}
