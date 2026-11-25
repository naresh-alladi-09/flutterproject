import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../../models/course_model.dart';
import '../../models/schedule_model.dart';
import '../../models/note_model.dart';

class StorageService {
  static const String _keyTasks = 'studyflow_tasks';
  static const String _keyCourses = 'studyflow_courses';
  static const String _keySchedules = 'studyflow_schedules';
  static const String _keyNotes = 'studyflow_notes';
  static const String _keyThemeMode = 'studyflow_theme_mode';
  static const String _keyStudyMinutes = 'studyflow_study_minutes';
  static const String _keyFirstRun = 'studyflow_first_run';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final isFirstRun = _prefs.getBool(_keyFirstRun) ?? true;
    if (isFirstRun) {
      await _seedInitialData();
      await _prefs.setBool(_keyFirstRun, false);
    }
  }

  // --- Seed Data ---
  Future<void> _seedInitialData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initial Courses
    final courses = [
      CourseModel(
        id: 'c1',
        name: 'Mobile App Development',
        code: 'CS305',
        instructor: 'Dr. Grace Hopper',
        room: 'Tech Hub Lab 3',
        colorValue: 0xFF6366F1, // Indigo
      ),
      CourseModel(
        id: 'c2',
        name: 'Calculus & Linear Algebra',
        code: 'MATH201',
        instructor: 'Dr. Katherine Johnson',
        room: 'Math Building 302',
        colorValue: 0xFF10B981, // Emerald
      ),
      CourseModel(
        id: 'c3',
        name: 'Modern Physics',
        code: 'PHYS102',
        instructor: 'Prof. Richard Feynman',
        room: 'Science Hall 105',
        colorValue: 0xFFF59E0B, // Amber
      ),
      CourseModel(
        id: 'c4',
        name: 'Data Structures & Algorithms',
        code: 'CS101',
        instructor: 'Prof. Alan Turing',
        room: 'Computing Lab B4',
        colorValue: 0xFF06B6D4, // Cyan
      ),
      CourseModel(
        id: 'c5',
        name: 'Academic Writing & Research',
        code: 'ENG105',
        instructor: 'Prof. Maya Angelou',
        room: 'Humanities 210',
        colorValue: 0xFF8B5CF6, // Purple
      ),
    ];
    await saveCourses(courses);

    // Initial Tasks
    final tasks = [
      TaskModel(
        id: 't1',
        title: 'Complete Flutter Task Manager App Project',
        description: 'Implement state management, responsive UI, Pomodoro timer, and local storage.',
        courseId: 'c1',
        courseName: 'Mobile App Development',
        category: 'Project',
        priority: 'Urgent',
        dueDate: today.add(const Duration(days: 1)),
        dueTime: '23:59',
        isCompleted: false,
        estimatedPomodoros: 4,
        completedPomodoros: 2,
        subtasks: [
          SubTask(id: 's1', title: 'Design Material 3 themes & color palette', isCompleted: true),
          SubTask(id: 's2', title: 'Build Task, Course, & Timetable models', isCompleted: true),
          SubTask(id: 's3', title: 'Implement Pomodoro timer with audio ticks', isCompleted: true),
          SubTask(id: 's4', title: 'Write comprehensive documentation & tests', isCompleted: false),
        ],
      ),
      TaskModel(
        id: 't2',
        title: 'Calculus Assignment #4: Optimization Problems',
        description: 'Complete problem sets 4.1 to 4.5 from page 142. Show all derivation steps.',
        courseId: 'c2',
        courseName: 'Calculus & Linear Algebra',
        category: 'Homework',
        priority: 'High',
        dueDate: today,
        dueTime: '18:00',
        isCompleted: false,
        estimatedPomodoros: 3,
        completedPomodoros: 1,
        subtasks: [
          SubTask(id: 's5', title: 'Review lecture 8 notes on extreme values', isCompleted: true),
          SubTask(id: 's6', title: 'Solve problems 1-10 on paper', isCompleted: false),
          SubTask(id: 's7', title: 'Scan and upload PDF to course portal', isCompleted: false),
        ],
      ),
      TaskModel(
        id: 't3',
        title: 'Physics Lab Report: Optics & Refraction',
        description: 'Analyze experimental data for Snell law and calculate index of refraction.',
        courseId: 'c3',
        courseName: 'Modern Physics',
        category: 'Assignment',
        priority: 'Medium',
        dueDate: today.add(const Duration(days: 3)),
        dueTime: '17:00',
        isCompleted: false,
        estimatedPomodoros: 2,
        completedPomodoros: 0,
        subtasks: [
          SubTask(id: 's8', title: 'Plot scatter chart in spreadsheet', isCompleted: false),
          SubTask(id: 's9', title: 'Write error analysis section', isCompleted: false),
        ],
      ),
      TaskModel(
        id: 't4',
        title: 'Midterm Exam Preparation: Trees & Graphs',
        description: 'Revise binary search trees, BFS, DFS, and Dijkstra algorithm.',
        courseId: 'c4',
        courseName: 'Data Structures & Algorithms',
        category: 'Exam Prep',
        priority: 'High',
        dueDate: today.add(const Duration(days: 5)),
        dueTime: '09:00',
        isCompleted: false,
        estimatedPomodoros: 6,
        completedPomodoros: 0,
        subtasks: [
          SubTask(id: 's10', title: 'Practice tree traversals on LeetCode', isCompleted: false),
          SubTask(id: 's11', title: 'Review past midterm papers from 2024', isCompleted: false),
        ],
      ),
      TaskModel(
        id: 't5',
        title: 'Submit Research Essay Outline',
        description: 'Two-page outline with at least 5 peer-reviewed scholarly citations.',
        courseId: 'c5',
        courseName: 'Academic Writing & Research',
        category: 'Assignment',
        priority: 'Low',
        dueDate: today.subtract(const Duration(days: 1)),
        dueTime: '12:00',
        isCompleted: true,
        estimatedPomodoros: 2,
        completedPomodoros: 2,
        subtasks: [
          SubTask(id: 's12', title: 'Formulate primary thesis statement', isCompleted: true),
          SubTask(id: 's13', title: 'Gather library journal articles', isCompleted: true),
        ],
      ),
    ];
    await saveTasks(tasks);

    // Initial Weekly Timetable
    final schedules = [
      ScheduleModel(
        id: 'sch1',
        courseId: 'c4',
        courseName: 'Data Structures & Algorithms',
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '10:30',
        room: 'Computing Lab B4',
        instructor: 'Prof. Alan Turing',
        colorValue: 0xFF06B6D4,
      ),
      ScheduleModel(
        id: 'sch2',
        courseId: 'c2',
        courseName: 'Calculus & Linear Algebra',
        dayOfWeek: 1, // Monday
        startTime: '11:00',
        endTime: '12:30',
        room: 'Math Building 302',
        instructor: 'Dr. Katherine Johnson',
        colorValue: 0xFF10B981,
      ),
      ScheduleModel(
        id: 'sch3',
        courseId: 'c1',
        courseName: 'Mobile App Development',
        dayOfWeek: 2, // Tuesday
        startTime: '10:00',
        endTime: '12:00',
        room: 'Tech Hub Lab 3',
        instructor: 'Dr. Grace Hopper',
        colorValue: 0xFF6366F1,
      ),
      ScheduleModel(
        id: 'sch4',
        courseId: 'c3',
        courseName: 'Modern Physics',
        dayOfWeek: 2, // Tuesday
        startTime: '14:00',
        endTime: '15:30',
        room: 'Science Hall 105',
        instructor: 'Prof. Richard Feynman',
        colorValue: 0xFFF59E0B,
      ),
      ScheduleModel(
        id: 'sch5',
        courseId: 'c4',
        courseName: 'Data Structures & Algorithms',
        dayOfWeek: 3, // Wednesday
        startTime: '09:00',
        endTime: '10:30',
        room: 'Computing Lab B4',
        instructor: 'Prof. Alan Turing',
        colorValue: 0xFF06B6D4,
      ),
      ScheduleModel(
        id: 'sch6',
        courseId: 'c5',
        courseName: 'Academic Writing & Research',
        dayOfWeek: 3, // Wednesday
        startTime: '13:00',
        endTime: '14:30',
        room: 'Humanities 210',
        instructor: 'Prof. Maya Angelou',
        colorValue: 0xFF8B5CF6,
      ),
      ScheduleModel(
        id: 'sch7',
        courseId: 'c2',
        courseName: 'Calculus & Linear Algebra',
        dayOfWeek: 4, // Thursday
        startTime: '11:00',
        endTime: '12:30',
        room: 'Math Building 302',
        instructor: 'Dr. Katherine Johnson',
        colorValue: 0xFF10B981,
      ),
      ScheduleModel(
        id: 'sch8',
        courseId: 'c1',
        courseName: 'Mobile App Development',
        dayOfWeek: 5, // Friday
        startTime: '13:30',
        endTime: '16:00',
        room: 'Tech Hub Lab 3',
        instructor: 'Dr. Grace Hopper',
        colorValue: 0xFF6366F1,
      ),
    ];
    await saveSchedules(schedules);

    // Initial Notes
    final notes = [
      NoteModel(
        id: 'n1',
        title: 'Big-O Complexities Cheat Sheet',
        content: 'Array access: O(1)\nBinary Search: O(log n)\nMerge Sort / Quick Sort (avg): O(n log n)\nMatrix Multiplication (naive): O(n^3)\nRemember worst case for QuickSort is O(n^2) if pivot selection is unoptimized!',
        courseId: 'c4',
        courseName: 'Data Structures & Algorithms',
        isPinned: true,
        colorValue: 0xFF06B6D4,
      ),
      NoteModel(
        id: 'n2',
        title: 'Calculus Derivative Formulas',
        content: 'd/dx [sin x] = cos x\nd/dx [cos x] = -sin x\nd/dx [e^x] = e^x\nd/dx [ln x] = 1/x\nProduct Rule: (uv)\' = u\'v + uv\'\nQuotient Rule: (u/v)\' = (u\'v - uv\') / v^2',
        courseId: 'c2',
        courseName: 'Calculus & Linear Algebra',
        isPinned: true,
        colorValue: 0xFF10B981,
      ),
      NoteModel(
        id: 'n3',
        title: 'Flutter Architecture Best Practices',
        content: '1. Separate business logic from UI widgets with ChangeNotifier Providers.\n2. Keep models immutable using copyWith.\n3. Cache and persist with SharedPreferences.\n4. Design responsive layouts supporting both mobile and desktop screens.',
        courseId: 'c1',
        courseName: 'Mobile App Development',
        isPinned: false,
        colorValue: 0xFF6366F1,
      ),
    ];
    await saveNotes(notes);

    await _prefs.setInt(_keyStudyMinutes, 75);
  }

  // --- Tasks Persistence ---
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(_keyTasks, json.encode(list));
  }

  List<TaskModel> loadTasks() {
    final raw = _prefs.getString(_keyTasks);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((item) => TaskModel.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Courses Persistence ---
  Future<void> saveCourses(List<CourseModel> courses) async {
    final list = courses.map((c) => c.toMap()).toList();
    await _prefs.setString(_keyCourses, json.encode(list));
  }

  List<CourseModel> loadCourses() {
    final raw = _prefs.getString(_keyCourses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((item) => CourseModel.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Schedules Persistence ---
  Future<void> saveSchedules(List<ScheduleModel> schedules) async {
    final list = schedules.map((s) => s.toMap()).toList();
    await _prefs.setString(_keySchedules, json.encode(list));
  }

  List<ScheduleModel> loadSchedules() {
    final raw = _prefs.getString(_keySchedules);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((item) => ScheduleModel.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Notes Persistence ---
  Future<void> saveNotes(List<NoteModel> notes) async {
    final list = notes.map((n) => n.toMap()).toList();
    await _prefs.setString(_keyNotes, json.encode(list));
  }

  List<NoteModel> loadNotes() {
    final raw = _prefs.getString(_keyNotes);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw);
      return decoded.map((item) => NoteModel.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Study Minutes Persistence ---
  int getStudyMinutes() => _prefs.getInt(_keyStudyMinutes) ?? 0;
  Future<void> addStudyMinutes(int minutes) async {
    final current = getStudyMinutes();
    await _prefs.setInt(_keyStudyMinutes, current + minutes);
  }

  // --- Theme Mode ---
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async => await _prefs.setString(_keyThemeMode, mode);

  // Reset to default data
  Future<void> resetAllData() async {
    await _prefs.clear();
    await _seedInitialData();
  }
}

