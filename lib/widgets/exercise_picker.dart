import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';

/// 动作选择器 bottom sheet
class ExercisePickerSheet extends StatefulWidget {
  final String muscleGroup;
  final List<Exercise> recentExercises;
  final List<Exercise> allExercises;
  final ValueChanged<Exercise> onSelected;

  const ExercisePickerSheet({
    super.key,
    required this.muscleGroup,
    required this.recentExercises,
    required this.allExercises,
    required this.onSelected,
  });

  static Future<Exercise?> show(
    BuildContext context, {
    required String muscleGroup,
    required List<Exercise> recentExercises,
    required List<Exercise> allExercises,
  }) async {
    return showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ExercisePickerSheet(
        muscleGroup: muscleGroup,
        recentExercises: recentExercises,
        allExercises: allExercises,
        onSelected: (e) => Navigator.pop(ctx, e),
      ),
    );
  }

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final hasRecent = widget.recentExercises.isNotEmpty;
    _tabController = TabController(
      length: hasRecent ? 2 : 1,
      vsync: this,
      initialIndex: hasRecent ? 0 : 0,
    );
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _filtered {
    if (_searchQuery.isEmpty) return widget.allExercises;
    return widget.allExercises.where((e) {
      return e.nameZh.contains(_searchQuery) ||
          e.nameEn.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final hasRecent = widget.recentExercises.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 拖拽把手
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // 标题 & 搜索
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.selectExercise,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索 / Search',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tab 切换（最近 / 全部）
            if (hasRecent)
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.recentExercises),
                  Tab(text: l10n.allExercises),
                ],
              ),

            // 列表
            Expanded(
              child: hasRecent
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(widget.recentExercises, locale),
                        _buildList(_filtered, locale),
                      ],
                    )
                  : _buildList(_filtered, locale),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(List<Exercise> exercises, String locale) {
    if (exercises.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noExercises,
            style: const TextStyle(color: AppColors.textHint)),
      );
    }
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, i) {
        final e = exercises[i];
        return ListTile(
          title: Text(e.localizedName(locale),
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: locale.startsWith('zh') && e.nameEn.isNotEmpty
              ? Text(e.nameEn, style: const TextStyle(fontSize: 12))
              : null,
          onTap: () => widget.onSelected(e),
        );
      },
    );
  }
}
