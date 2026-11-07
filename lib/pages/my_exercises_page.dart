import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../di/service_provider.dart';
import '../models/exercise.dart';
import 'add_exercise_page.dart';

class MyExercisesPage extends StatefulWidget {
  const MyExercisesPage({super.key});

  @override
  State<MyExercisesPage> createState() => _MyExercisesPageState();
}

class _MyExercisesPageState extends State<MyExercisesPage> {
  List<Exercise> _exercises = [];

  static const _muscleGroupNames = {
    'chest': '胸',
    'back': '背',
    'shoulders': '肩',
    'legs': '腿',
    'arms': '手臂',
    'core': '核心',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final sp = ServiceProvider.of(context);
    final exercises = await sp.exerciseService.getCustomExercises();
    if (mounted) setState(() => _exercises = exercises);
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text('确定要删除"${exercise.nameZh}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final sp = ServiceProvider.of(context);
      await sp.exerciseService.deleteExercise(exercise.id!);
      _loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myExercises),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExercisePage()),
          );
          _loadExercises();
        },
        child: const Icon(Icons.add),
      ),
      body: _exercises.isEmpty
          ? Center(
              child: Text(l10n.noCustomExercises,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            )
          : ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return ListTile(
                  title: Text(exercise.nameZh),
                  subtitle: exercise.nameEn != null
                      ? Text(exercise.nameEn!)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          _muscleGroupNames[exercise.muscleGroup] ??
                              exercise.muscleGroup,
                          style: theme.textTheme.labelSmall,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        onPressed: () => _deleteExercise(exercise),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
