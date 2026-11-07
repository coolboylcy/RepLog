import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../di/service_provider.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameZhController = TextEditingController();
  final _nameEnController = TextEditingController();
  String? _selectedMuscleGroup;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleGroup == null) return;

    final sp = ServiceProvider.of(context);
    await sp.exerciseService.addCustomExercise(
      nameZh: _nameZhController.text.trim(),
      nameEn: _nameEnController.text.trim().isEmpty
          ? null
          : _nameEnController.text.trim(),
      muscleGroup: _selectedMuscleGroup!,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameZhController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newExercise),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameZhController,
              decoration: InputDecoration(
                labelText: l10n.exerciseNameZh,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                labelText: l10n.exerciseNameEn,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.selectMuscleGroup,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups.map((group) {
                final isSelected = _selectedMuscleGroup == group;
                return FilterChip(
                  label: Text(_muscleGroupNames[group] ?? group),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedMuscleGroup = group);
                  },
                );
              }).toList(),
            ),
            if (_selectedMuscleGroup == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '请选择肌群',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
