import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_colors.dart';

class AddEditCourseDialog extends StatefulWidget {
  final CourseModel? courseToEdit;

  const AddEditCourseDialog({super.key, this.courseToEdit});

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late TextEditingController _roomController;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    final edit = widget.courseToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _codeController = TextEditingController(text: edit?.code ?? '');
    _instructorController = TextEditingController(text: edit?.instructor ?? '');
    _roomController = TextEditingController(text: edit?.room ?? '');
    _selectedColorValue = edit?.colorValue ?? AppColors.courseColors.first.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.courseToEdit != null;
    final course = CourseModel(
      id: isEdit ? widget.courseToEdit!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      instructor: _instructorController.text.trim(),
      room: _roomController.text.trim(),
      colorValue: _selectedColorValue,
    );

    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.courseToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? 'Edit Course' : 'Add New Course', style: const TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g. Computer Science 101',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter course name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Course Code *',
                    hintText: 'e.g. CS101, MATH201',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter course code' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor / Professor',
                    hintText: 'e.g. Dr. Turing',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Classroom / Lab',
                    hintText: 'e.g. Science Building 204',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose Course Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppColors.courseColors.map((color) {
                    final isSelected = _selectedColorValue == color.value;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorValue = color.value),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 2)]
                              : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(isEdit ? 'Save Changes' : 'Add Course'),
        ),
      ],
    );
  }
}

