import 'dart:convert';
import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final String room;
  final int colorValue;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
    this.instructor = '',
    this.room = '',
    this.colorValue = 0xFF6366F1,
  });

  Color get color => Color(colorValue);

  CourseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    String? room,
    int? colorValue,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      room: room ?? this.room,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'room': room,
      'colorValue': colorValue,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      instructor: map['instructor'] ?? '',
      room: map['room'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF6366F1,
    );
  }

  String toJson() => json.encode(toMap());

  factory CourseModel.fromJson(String source) => CourseModel.fromMap(json.decode(source));
}

