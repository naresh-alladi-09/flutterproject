import 'dart:convert';

class ScheduleModel {
  final String id;
  final String courseId;
  final String courseName;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // "09:00"
  final String endTime;   // "10:30"
  final String room;
  final String instructor;
  final int colorValue;

  ScheduleModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room = '',
    this.instructor = '',
    this.colorValue = 0xFF6366F1,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String get dayShortName {
    switch (dayOfWeek) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Unk';
    }
  }

  ScheduleModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? instructor,
    int? colorValue,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      instructor: instructor ?? this.instructor,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'instructor': instructor,
      'colorValue': colorValue,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 1,
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '10:00',
      room: map['room'] ?? '',
      instructor: map['instructor'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF6366F1,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) => ScheduleModel.fromMap(json.decode(source));
}

