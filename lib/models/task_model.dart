import 'dart:convert';

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final String category; // Assignment, Exam Prep, Project, Homework, etc.
  final String priority; // Urgent, High, Medium, Low
  final DateTime dueDate;
  final String dueTime; // "14:30"
  final bool isCompleted;
  final List<SubTask> subtasks;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.courseId = '',
    this.courseName = '',
    this.category = 'Assignment',
    this.priority = 'Medium',
    required this.dueDate,
    this.dueTime = '23:59',
    this.isCompleted = false,
    this.subtasks = const [],
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (taskDate.isBefore(today)) return true;
    if (taskDate.isAtSameMomentAs(today)) {
      // Check time
      final parts = dueTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 23;
        final minute = int.tryParse(parts[1]) ?? 59;
        final dueDateTime = DateTime(today.year, today.month, today.day, hour, minute);
        return now.isAfter(dueDateTime);
      }
    }
    return false;
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  double get progressPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? courseName,
    String? category,
    String? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    List<SubTask>? subtasks,
    int? estimatedPomodoros,
    int? completedPomodoros,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseName': courseName,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((x) => x.toMap()).toList(),
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      category: map['category'] ?? 'Assignment',
      priority: map['priority'] ?? 'Medium',
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      dueTime: map['dueTime'] ?? '23:59',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: map['subtasks'] != null
          ? List<SubTask>.from((map['subtasks'] as List).map((x) => SubTask.fromMap(x)))
          : [],
      estimatedPomodoros: map['estimatedPomodoros'] ?? 1,
      completedPomodoros: map['completedPomodoros'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) => TaskModel.fromMap(json.decode(source));
}

