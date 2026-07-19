import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnatomyMuscleMap extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String> onSelected;

  const AnatomyMuscleMap({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final group = _hitTest(details.localPosition, size);
            if (group != null) onSelected(group);
          },
          child: CustomPaint(
            painter: _AnatomyPainter(selectedGroup),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  String? _hitTest(Offset point, Size size) {
    final w = size.width;
    final h = size.height;
    final x = point.dx / w;
    final y = point.dy / h;

    if (y < 0.25 && x > 0.34 && x < 0.66) return 'shoulders';
    if (y >= 0.25 && y < 0.43 && x > 0.34 && x < 0.66) return 'chest';
    if (y >= 0.32 && y < 0.58 && x > 0.28 && x < 0.72) return 'back';
    if (y >= 0.42 && y < 0.62 && x > 0.38 && x < 0.62) return 'core';
    if (y >= 0.24 && y < 0.58 && (x <= 0.34 || x >= 0.66)) return 'arms';
    if (y >= 0.60 && x > 0.33 && x < 0.67) return 'legs';
    if (y >= 0.58 && (x <= 0.33 || x >= 0.67)) return 'full_body';
    return null;
  }
}

class _AnatomyPainter extends CustomPainter {
  final String? selectedGroup;

  _AnatomyPainter(this.selectedGroup);

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Rect r(double left, double top, double width, double height) =>
        Rect.fromLTWH(
          size.width * left,
          size.height * top,
          size.width * width,
          size.height * height,
        );

    void drawPart(String group, RRect shape) {
      final selected = selectedGroup == group ||
          (selectedGroup == 'full_body' && group != 'core');
      final color = AppColors.forMuscleGroup(
        selectedGroup == 'full_body' ? 'full_body' : group,
      );
      canvas.drawRRect(
        shape,
        Paint()
          ..color = selected ? color.withValues(alpha: 0.76) : basePaint.color
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(shape, linePaint);
    }

    canvas.drawOval(r(0.41, 0.03, 0.18, 0.12), basePaint);
    canvas.drawOval(r(0.41, 0.03, 0.18, 0.12), linePaint);

    drawPart(
        'shoulders',
        RRect.fromRectAndRadius(
            r(0.30, 0.18, 0.40, 0.10), const Radius.circular(18)));
    drawPart(
        'chest',
        RRect.fromRectAndRadius(
            r(0.35, 0.27, 0.30, 0.16), const Radius.circular(18)));
    drawPart(
        'back',
        RRect.fromRectAndRadius(
            r(0.32, 0.32, 0.36, 0.18), const Radius.circular(18)));
    drawPart(
        'core',
        RRect.fromRectAndRadius(
            r(0.39, 0.45, 0.22, 0.16), const Radius.circular(14)));
    drawPart(
        'arms',
        RRect.fromRectAndRadius(
            r(0.18, 0.26, 0.15, 0.34), const Radius.circular(18)));
    drawPart(
        'arms',
        RRect.fromRectAndRadius(
            r(0.67, 0.26, 0.15, 0.34), const Radius.circular(18)));
    drawPart(
        'legs',
        RRect.fromRectAndRadius(
            r(0.35, 0.62, 0.13, 0.32), const Radius.circular(18)));
    drawPart(
        'legs',
        RRect.fromRectAndRadius(
            r(0.52, 0.62, 0.13, 0.32), const Radius.circular(18)));

    final highlight = selectedGroup == null
        ? AppColors.primary
        : AppColors.forMuscleGroup(selectedGroup!);
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.53),
      4,
      Paint()..color = highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _AnatomyPainter oldDelegate) =>
      oldDelegate.selectedGroup != selectedGroup;
}
