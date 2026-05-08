import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import '../widgets/muscle_group_chips.dart';
import 'add_exercise_page.dart';

class MyExercisesPage extends StatefulWidget {
  const MyExercisesPage({super.key});

  @override
  State<MyExercisesPage> createState() => _MyExercisesPageState();
}

class _MyExercisesPageState extends State<MyExercisesPage> {
  List<Exercise> _exercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ServiceLocator.of(context).exerciseService.getAll();
    if (mounted) {
      setState(() {
        _exercises = all.where((e) => e.isCustom).toList();
        _loading = false;
      });
    }
  }

  Future<void> _delete(Exercise exercise) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('删除「${exercise.nameZh}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ServiceLocator.of(context).exerciseRepository.delete(exercise.id!);
    if (mounted) {
      setState(() => _exercises.removeWhere((e) => e.id == exercise.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exerciseDeleted)),
      );
    }
  }

  Future<void> _addExercise() async {
    final result = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (_) => const AddExercisePage()),
    );
    if (result != null) {
      setState(() => _exercises.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myExercises),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addExercise,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(l10n.noCustomExercises,
                          style:
                              const TextStyle(color: AppColors.textHint)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addExercise),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _exercises.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (ctx, i) {
                    final e = _exercises[i];
                    return ListTile(
                      title: Text(e.localizedName(locale),
                          style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Row(
                        children: [MuscleGroupTag(muscleGroup: e.muscleGroup)],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () => _delete(e),
                      ),
                    );
                  },
                ),
    );
  }
}
