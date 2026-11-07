import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../di/service_provider.dart';
import '../pages/add_exercise_page.dart';

class ExercisePicker extends StatefulWidget {
  final ValueChanged<Exercise> onSelected;

  const ExercisePicker({super.key, required this.onSelected});

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  List<Exercise> _exercises = [];
  String? _selectedGroup;
  String _searchQuery = '';

  static const _muscleGroups = [
    'chest', 'back', 'shoulders', 'legs', 'arms', 'core',
  ];

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
    final exercises = await sp.exerciseService.getAllExercises();
    if (mounted) setState(() => _exercises = exercises);
  }

  List<Exercise> get _filteredExercises {
    var filtered = _exercises;
    if (_selectedGroup != null) {
      filtered = filtered.where((e) => e.muscleGroup == _selectedGroup).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
          e.nameZh.toLowerCase().contains(query) ||
          (e.nameEn?.toLowerCase().contains(query) ?? false)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('选择动作',
                          style: theme.textTheme.titleLarge),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddExercisePage()),
                        );
                        _loadExercises();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('新建动作'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: '搜索动作...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('全部'),
                        selected: _selectedGroup == null,
                        onSelected: (_) =>
                            setState(() => _selectedGroup = null),
                      ),
                    ),
                    ..._muscleGroups.map((group) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(_muscleGroupNames[group] ?? group),
                            selected: _selectedGroup == group,
                            onSelected: (_) =>
                                setState(() => _selectedGroup = group),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return ListTile(
                      title: Text(exercise.nameZh),
                      subtitle: exercise.nameEn != null
                          ? Text(exercise.nameEn!,
                              style: theme.textTheme.bodySmall)
                          : null,
                      trailing: Chip(
                        label: Text(
                          _muscleGroupNames[exercise.muscleGroup] ??
                              exercise.muscleGroup,
                          style: theme.textTheme.labelSmall,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onTap: () {
                        widget.onSelected(exercise);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
