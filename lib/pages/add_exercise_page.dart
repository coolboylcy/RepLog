import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/service_locator.dart';
import '../theme/app_colors.dart';

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
  bool _saving = false;

  static const _muscleGroups = [
    'chest',
    'back',
    'shoulders',
    'legs',
    'arms',
    'core',
    'full_body'
  ];

  @override
  void dispose() {
    _nameZhController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.selectMuscleGroup)),
      );
      return;
    }
    setState(() => _saving = true);
    final svc = ServiceLocator.of(context).exerciseService;
    final exercise = await svc.addCustomExercise(
      nameZh: _nameZhController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      muscleGroup: _selectedMuscleGroup!,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.exerciseAdded)),
      );
      Navigator.pop(context, exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addExercise),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.save,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入动作名称' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                labelText: l10n.exerciseNameEn,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            Text(l10n.selectMuscleGroup,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups.map((group) {
                final selected = _selectedMuscleGroup == group;
                final color = AppColors.forMuscleGroup(group);
                return ChoiceChip(
                  label: Text(_muscleLabel(group, locale)),
                  selected: selected,
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? color : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedMuscleGroup = group),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _muscleLabel(String group, String locale) {
    final l10n = AppLocalizations.of(context)!;
    switch (group) {
      case 'chest':
        return l10n.muscleChest;
      case 'back':
        return l10n.muscleBack;
      case 'shoulders':
        return l10n.muscleShoulders;
      case 'legs':
        return l10n.muscleLegs;
      case 'arms':
        return l10n.muscleArms;
      case 'core':
        return l10n.muscleCore;
      case 'full_body':
        return l10n.muscleFullBody;
      default:
        return group;
    }
  }
}
