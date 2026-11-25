import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/schedule_model.dart';
import '../../providers/course_provider.dart';
import '../../core/constants/app_colors.dart';

class AddClassDialog extends StatefulWidget {
  final int initialDayOfWeek;
  final ScheduleModel? scheduleToEdit;

  const AddClassDialog({
    super.key,
    required this.initialDayOfWeek,
    this.scheduleToEdit,
  });

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCourseId;
  late int _selectedDayOfWeek;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _roomController;
  late TextEditingController _instructorController;

  final List<Map<String, dynamic>> _days = [
    {'day': 1, 'name': 'Monday'},
    {'day': 2, 'name': 'Tuesday'},
    {'day': 3, 'name': 'Wednesday'},
    {'day': 4, 'name': 'Thursday'},
    {'day': 5, 'name': 'Friday'},
    {'day': 6, 'name': 'Saturday'},
    {'day': 7, 'name': 'Sunday'},
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.scheduleToEdit;
    _selectedDayOfWeek = edit?.dayOfWeek ?? widget.initialDayOfWeek;
    _selectedCourseId = edit?.courseId;
    _roomController = TextEditingController(text: edit?.room ?? '');
    _instructorController = TextEditingController(text: edit?.instructor ?? '');

    if (edit != null) {
      final sParts = edit.startTime.split(':');
      final eParts = edit.endTime.split(':');
      _startTime = TimeOfDay(hour: int.tryParse(sParts[0]) ?? 9, minute: int.tryParse(sParts[1]) ?? 0);
      _endTime = TimeOfDay(hour: int.tryParse(eParts[0]) ?? 10, minute: int.tryParse(eParts[1]) ?? 30);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 30);
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course for this class.')),
      );
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final course = courseProvider.getCourseById(_selectedCourseId!);

    final startStr =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    final isEdit = widget.scheduleToEdit != null;
    final schedule = ScheduleModel(
      id: isEdit ? widget.scheduleToEdit!.id : const Uuid().v4(),
      courseId: _selectedCourseId!,
      courseName: course?.name ?? 'Course Class',
      dayOfWeek: _selectedDayOfWeek,
      startTime: startStr,
      endTime: endStr,
      room: _roomController.text.trim().isNotEmpty
          ? _roomController.text.trim()
          : (course?.room ?? ''),
      instructor: _instructorController.text.trim().isNotEmpty
          ? _instructorController.text.trim()
          : (course?.instructor ?? ''),
      colorValue: course?.colorValue ?? 0xFF6366F1,
    );

    Navigator.of(context).pop(schedule);
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final isEdit = widget.scheduleToEdit != null;

    final startStr =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? 'Edit Class Schedule' : 'Add Class Schedule', style: const TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day of Week
                DropdownButtonFormField<int>(
                  value: _selectedDayOfWeek,
                  decoration: const InputDecoration(labelText: 'Day of Week'),
                  items: _days.map((d) {
                    return DropdownMenuItem<int>(
                      value: d['day'] as int,
                      child: Text(d['name'] as String),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDayOfWeek = val);
                  },
                ),
                const SizedBox(height: 12),

                // Course selector
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: const InputDecoration(labelText: 'Select Course *'),
                  items: courseProvider.courses.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text('${c.code} - ${c.name}'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCourseId = val;
                      if (val != null) {
                        final c = courseProvider.getCourseById(val);
                        if (c != null) {
                          if (_roomController.text.isEmpty) _roomController.text = c.room;
                          if (_instructorController.text.isEmpty) _instructorController.text = c.instructor;
                        }
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Select a course' : null,
                ),
                const SizedBox(height: 12),

                // Start and End Times
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Start Time'),
                          child: Text(startStr),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End Time'),
                          child: Text(endStr),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Room
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room / Building',
                    hintText: 'e.g. Science Hall 105',
                  ),
                ),
                const SizedBox(height: 12),

                // Instructor
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Lecturer / Instructor',
                    hintText: 'e.g. Dr. Turing',
                  ),
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
          child: Text(isEdit ? 'Save Changes' : 'Add Class'),
        ),
      ],
    );
  }
}

