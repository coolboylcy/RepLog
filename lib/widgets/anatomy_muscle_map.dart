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
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/anatomy_muscle_map.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              ..._zones.map(
                (zone) => _HitZone(
                  zone: zone,
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  selected: selectedGroup == zone.group ||
                      selectedGroup == 'full_body',
                  onTap: () => onSelected(zone.group),
                ),
              ),
              if (selectedGroup != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.forMuscleGroup(selectedGroup!)
                          .withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        '已选择',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HitZone extends StatelessWidget {
  final _MuscleZone zone;
  final Size size;
  final bool selected;
  final VoidCallback onTap;

  const _HitZone({
    required this.zone,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: zone.rect.left * size.width,
      top: zone.rect.top * size.height,
      width: zone.rect.width * size.width,
      height: zone.rect.height * size.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.forMuscleGroup(zone.group).withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? Border.all(
                    color: AppColors.forMuscleGroup(zone.group),
                    width: 1.4,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _MuscleZone {
  final String group;
  final Rect rect;

  const _MuscleZone(this.group, this.rect);
}

const _zones = [
  _MuscleZone('shoulders', Rect.fromLTWH(0.12, 0.16, 0.78, 0.13)),
  _MuscleZone('chest', Rect.fromLTWH(0.09, 0.21, 0.33, 0.19)),
  _MuscleZone('back', Rect.fromLTWH(0.57, 0.18, 0.34, 0.30)),
  _MuscleZone('arms', Rect.fromLTWH(0.02, 0.25, 0.22, 0.35)),
  _MuscleZone('arms', Rect.fromLTWH(0.76, 0.24, 0.22, 0.36)),
  _MuscleZone('core', Rect.fromLTWH(0.18, 0.35, 0.22, 0.22)),
  _MuscleZone('legs', Rect.fromLTWH(0.14, 0.55, 0.30, 0.38)),
  _MuscleZone('legs', Rect.fromLTWH(0.58, 0.53, 0.30, 0.41)),
];
