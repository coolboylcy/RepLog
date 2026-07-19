import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class ExerciseDemoLoop extends StatefulWidget {
  final String muscleGroup;
  final double size;

  const ExerciseDemoLoop({
    super.key,
    required this.muscleGroup,
    this.size = 72,
  });

  @override
  State<ExerciseDemoLoop> createState() => _ExerciseDemoLoopState();
}

class _ExerciseDemoLoopState extends State<ExerciseDemoLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.Image? _atlas;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _loadAtlas();
  }

  Future<void> _loadAtlas() async {
    final data = await rootBundle.load('assets/images/exercise_demo_atlas.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _atlas = frame.image);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forMuscleGroup(widget.muscleGroup);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _atlas == null
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                )
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final frame = (_controller.value * 4).floor().clamp(0, 3);
                    return CustomPaint(
                      painter: _AtlasFramePainter(
                        image: _atlas!,
                        row: _rowForMuscle(widget.muscleGroup),
                        frame: frame,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  int _rowForMuscle(String group) {
    return switch (group) {
      'chest' => 0,
      'back' => 1,
      'shoulders' => 2,
      'legs' => 3,
      'arms' => 4,
      'core' => 5,
      'full_body' => 6,
      _ => 6,
    };
  }
}

class _AtlasFramePainter extends CustomPainter {
  final ui.Image image;
  final int row;
  final int frame;

  _AtlasFramePainter({
    required this.image,
    required this.row,
    required this.frame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = image.width / 4;
    final frameHeight = image.height / 7;
    final src = Rect.fromLTWH(
      frameWidth * frame,
      frameHeight * row,
      frameWidth,
      frameHeight,
    );
    final dst = Offset.zero & size;
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    canvas.drawColor(Colors.white, BlendMode.src);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _AtlasFramePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.row != row ||
        oldDelegate.frame != frame;
  }
}
