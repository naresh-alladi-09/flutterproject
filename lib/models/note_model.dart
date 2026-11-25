import 'dart:convert';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String courseId;
  final String courseName;
  final bool isPinned;
  final int colorValue;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.courseId = '',
    this.courseName = '',
    this.isPinned = false,
    this.colorValue = 0xFF6366F1,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? courseId,
    String? courseName,
    bool? isPinned,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'courseId': courseId,
      'courseName': courseName,
      'isPinned': isPinned,
      'colorValue': colorValue,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      isPinned: map['isPinned'] ?? false,
      colorValue: map['colorValue'] ?? 0xFF6366F1,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) => NoteModel.fromMap(json.decode(source));
}

