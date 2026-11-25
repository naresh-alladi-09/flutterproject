import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../providers/course_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? noteToEdit;

  const AddEditNoteScreen({super.key, this.noteToEdit});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedCourseId;
  late bool _isPinned;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    final edit = widget.noteToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _contentController = TextEditingController(text: edit?.content ?? '');
    _selectedCourseId = edit?.courseId.isNotEmpty == true ? edit!.courseId : null;
    _isPinned = edit?.isPinned ?? false;
    _selectedColorValue = edit?.colorValue ?? AppColors.courseColors[0].value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    String courseName = '';
    if (_selectedCourseId != null) {
      final course = courseProvider.getCourseById(_selectedCourseId!);
      if (course != null) courseName = course.name;
    }

    final isEdit = widget.noteToEdit != null;
    final note = NoteModel(
      id: isEdit ? widget.noteToEdit!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      courseId: _selectedCourseId ?? '',
      courseName: courseName,
      isPinned: _isPinned,
      colorValue: _selectedColorValue,
      updatedAt: DateTime.now(),
    );

    if (isEdit) {
      noteProvider.updateNote(note);
    } else {
      noteProvider.addNote(note);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final isEdit = widget.noteToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Note' : 'New Study Note', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: _isPinned ? 'Unpin' : 'Pin to Top',
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : null,
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(
            tooltip: 'Save Note',
            icon: const Icon(Icons.check, color: AppColors.primary, size: 28),
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                hintText: 'Note Title...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title for this note' : null,
            ),

            const SizedBox(height: 12),

            // Course selector & Color picker row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Link to course (optional)'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('General Note'),
                      ),
                      ...courseProvider.courses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course.id,
                          child: Text('${course.code} - ${course.name}'),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Color picker
            Wrap(
              spacing: 8,
              children: AppColors.courseColors.take(6).map((color) {
                final isSelected = _selectedColorValue == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = color.value),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 28),

            // Content
            TextFormField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 15, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Start writing your study formulas, lecture highlights, key concepts, or brainstorming thoughts...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

