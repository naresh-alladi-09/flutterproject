import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../core/services/storage_service.dart';

enum TaskSortOption { dueDateAsc, dueDateDesc, priority, title }

class TaskProvider with ChangeNotifier {
  final StorageService _storageService;
  List<TaskModel> _tasks = [];
  String _selectedFilter = 'All'; // All, Today, Upcoming, Completed, Overdue
  String? _selectedCourseFilter;
  String? _selectedPriorityFilter;
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.dueDateAsc;

  TaskProvider(this._storageService) {
    _loadTasks();
  }

  List<TaskModel> get allTasks => _tasks;
  String get selectedFilter => _selectedFilter;
  String? get selectedCourseFilter => _selectedCourseFilter;
  String? get selectedPriorityFilter => _selectedPriorityFilter;
  String get searchQuery => _searchQuery;
  TaskSortOption get sortOption => _sortOption;

  void _loadTasks() {
    _tasks = _storageService.loadTasks();
    notifyListeners();
  }

  // --- Filtering & Searching ---
  List<TaskModel> get filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var list = _tasks.where((task) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        final matchCourse = task.courseName.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCourse) return false;
      }

      // 2. Course Filter
      if (_selectedCourseFilter != null && _selectedCourseFilter!.isNotEmpty) {
        if (task.courseId != _selectedCourseFilter) return false;
      }

      // 3. Priority Filter
      if (_selectedPriorityFilter != null && _selectedPriorityFilter!.isNotEmpty) {
        if (task.priority.toLowerCase() != _selectedPriorityFilter!.toLowerCase()) return false;
      }

      // 4. Status Filter
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      switch (_selectedFilter) {
        case 'Today':
          return !task.isCompleted && taskDate.isAtSameMomentAs(today);
        case 'Upcoming':
          return !task.isCompleted && taskDate.isAfter(today);
        case 'Completed':
          return task.isCompleted;
        case 'Overdue':
          return task.isOverdue;
        case 'All':
        default:
          return true;
      }
    }).toList();

    // Sorting
    list.sort((a, b) {
      switch (_sortOption) {
        case TaskSortOption.dueDateAsc:
          return a.dueDate.compareTo(b.dueDate);
        case TaskSortOption.dueDateDesc:
          return b.dueDate.compareTo(a.dueDate);
        case TaskSortOption.priority:
          return _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
        case TaskSortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return list;
  }

  int _priorityWeight(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }

  // Setters for filters
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setCourseFilter(String? courseId) {
    _selectedCourseFilter = courseId;
    notifyListeners();
  }

  void setPriorityFilter(String? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void clearFilters() {
    _selectedFilter = 'All';
    _selectedCourseFilter = null;
    _selectedPriorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // --- Statistics ---
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasksCount => _tasks.where((t) => t.isOverdue).length;
  int get todayTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return !t.isCompleted && taskDate.isAtSameMomentAs(today);
    }).length;
  }

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / _tasks.length;
  }

  List<TaskModel> get upcomingDeadlines {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return pending.take(5).toList();
  }

  List<TaskModel> getTasksForCourse(String courseId) {
    return _tasks.where((t) => t.courseId == courseId).toList();
  }

  TaskModel? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- CRUD Operations ---
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _save();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _save();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _save();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = !task.isCompleted;
      // Also update subtasks to match if marking completed
      final updatedSubtasks = newStatus
          ? task.subtasks.map((s) => s.copyWith(isCompleted: true)).toList()
          : task.subtasks;

      _tasks[index] = task.copyWith(
        isCompleted: newStatus,
        subtasks: updatedSubtasks,
      );
      await _save();
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedSubtasks = task.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();

      final allCompleted = updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isCompleted);

      _tasks[index] = task.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
      );
      await _save();
    }
  }

  Future<void> addSubtask(String taskId, String title) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newSubtask = SubTask(
        id: const Uuid().v4(),
        title: title,
        isCompleted: false,
      );
      final updatedSubtasks = List<SubTask>.from(task.subtasks)..add(newSubtask);
      _tasks[index] = task.copyWith(subtasks: updatedSubtasks, isCompleted: false);
      await _save();
    }
  }

  Future<void> removeSubtask(String taskId, String subtaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedSubtasks = task.subtasks.where((s) => s.id != subtaskId).toList();
      _tasks[index] = task.copyWith(subtasks: updatedSubtasks);
      await _save();
    }
  }

  Future<void> incrementCompletedPomodoro(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(completedPomodoros: task.completedPomodoros + 1);
      await _save();
    }
  }

  Future<void> _save() async {
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  void refresh() {
    _loadTasks();
  }
}

