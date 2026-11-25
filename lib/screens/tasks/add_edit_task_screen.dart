import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../models/course_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/course_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;

  const AddEditTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _subtaskController = TextEditingController();

  String? _selectedCourseId;
  String _selectedCategory = 'Assignment';
  String _selectedPriority = 'Medium';
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;
  int _estimatedPomodoros = 2;
  List<SubTask> _subtasks = [];

  final List<String> _categories = [
    'Assignment',
    'Exam Prep',
    'Project',
    'Homework',
    'Reading',
    'Personal',
  ];

  final List<String> _priorities = ['Urgent', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    final edit = widget.taskToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _descriptionController = TextEditingController(text: edit?.description ?? '');
    _selectedCourseId = edit?.courseId.isNotEmpty == true ? edit!.courseId : null;
    _selectedCategory = edit?.category ?? 'Assignment';
    _selectedPriority = edit?.priority ?? 'Medium';
    _selectedDueDate = edit?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _estimatedPomodoros = edit?.estimatedPomodoros ?? 2;
    _subtasks = edit != null ? List<SubTask>.from(edit.subtasks) : [];

    if (edit != null && edit.dueTime.isNotEmpty) {
      final parts = edit.dueTime.split(':');
      if (parts.length == 2) {
        _selectedDueTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 23,
          minute: int.tryParse(parts[1]) ?? 59,
        );
      } else {
        _selectedDueTime = const TimeOfDay(hour: 23, minute: 59);
      }
    } else {
      _selectedDueTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );
    if (picked != null) {
      setState(() => _selectedDueTime = picked);
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: const Uuid().v4(),
          title: text,
          isCompleted: false,
        ));
      });
      _subtaskController.clear();
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    String courseName = '';
    if (_selectedCourseId != null) {
      final course = courseProvider.getCourseById(_selectedCourseId!);
      if (course != null) courseName = course.name;
    }

    final dueTimeStr =
        '${_selectedDueTime.hour.toString().padLeft(2, '0')}:${_selectedDueTime.minute.toString().padLeft(2, '0')}';

    final isEditing = widget.taskToEdit != null;
    final task = TaskModel(
      id: isEditing ? widget.taskToEdit!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      courseId: _selectedCourseId ?? '',
      courseName: courseName,
      category: _selectedCategory,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      dueTime: dueTimeStr,
      isCompleted: isEditing ? widget.taskToEdit!.isCompleted : false,
      subtasks: _subtasks,
      estimatedPomodoros: _estimatedPomodoros,
      completedPomodoros: isEditing ? widget.taskToEdit!.completedPomodoros : 0,
      createdAt: isEditing ? widget.taskToEdit!.createdAt : DateTime.now(),
    );

    if (isEditing) {
      taskProvider.updateTask(task);
    } else {
      taskProvider.addTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseProvider = Provider.of<CourseProvider>(context);
    final isEditing = widget.taskToEdit != null;

    final formattedTime =
        '${_selectedDueTime.hour.toString().padLeft(2, '0')}:${_selectedDueTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Academic Task', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Title Input
            const Text('Task Title *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Physics Lab Report or Calculus Problem Set',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter a title for this task';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Input
            const Text('Description / Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add guidelines, chapter references, rubric notes...',
              ),
            ),

            const SizedBox(height: 16),

            // Course Dropdown
            const Text('Course / Subject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              isExpanded: true,
              decoration: const InputDecoration(),
              hint: const Text('Select a course (optional)'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('General / Non-course'),
                ),
                ...courseProvider.courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course.id,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color(course.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${course.code} - ${course.name}'),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedCourseId = val),
            ),

            const SizedBox(height: 16),

            // Category Chips
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Priority Chips
            const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _priorities.map((p) {
                final isSelected = _selectedPriority == p;
                final color = AppColors.getPriorityColor(p);
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  selectedColor: color.withOpacity(0.2),
                  side: BorderSide(color: isSelected ? color : Colors.transparent),
                  labelStyle: TextStyle(
                    color: isSelected ? color : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _selectedPriority = p),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Date & Time Pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMM d, yyyy').format(_selectedDueDate)),
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedTime),
                              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Estimated Pomodoro Sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Study Focus (25 min blocks)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('$_estimatedPomodoros sessions (${_estimatedPomodoros * 25} mins)',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            Slider(
              value: _estimatedPomodoros.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              activeColor: AppColors.primary,
              label: '$_estimatedPomodoros sessions',
              onChanged: (val) => setState(() => _estimatedPomodoros = val.toInt()),
            ),

            const SizedBox(height: 16),

            // Subtasks Builder
            const Text('Subtasks / Action Checklist', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),

            // Existing added subtasks
            if (_subtasks.isNotEmpty)
              ..._subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(subtask.title, style: const TextStyle(fontSize: 13))),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        onPressed: () => _removeSubtask(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }),

            // Add new subtask row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    onSubmitted: (_) => _addSubtask(),
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask step...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubtask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Task Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Task',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

