import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class WeekActivityRow extends StatelessWidget {
  final List<bool> activity; // 7个元素，true=有训练

  const WeekActivityRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 从今天往前7天的星期标签
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _dayLabel(context, d.weekday, l10n);
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final trained = i < activity.length && activity[i];
        final isToday = i == 6;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: trained
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.08),
                border: isToday
                    ? Border.all(
                        color: AppColors.primary, width: 2)
                    : null,
              ),
              child: trained
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              dayLabels[i],
              style: TextStyle(
                fontSize: 10,
                color:
                    trained ? AppColors.primary : AppColors.textHint,
                fontWeight: isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _dayLabel(BuildContext context, int weekday, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale.startsWith('zh')) {
      const zh = ['一', '二', '三', '四', '五', '六', '日'];
      return zh[weekday - 1];
    } else {
      const en = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return en[weekday - 1];
    }
  }
}
