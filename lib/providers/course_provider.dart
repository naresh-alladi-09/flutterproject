import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../core/services/storage_service.dart';

class CourseProvider with ChangeNotifier {
  final StorageService _storageService;
  List<CourseModel> _courses = [];

  CourseProvider(this._storageService) {
    _loadCourses();
  }

  List<CourseModel> get courses => _courses;

  void _loadCourses() {
    _courses = _storageService.loadCourses();
    notifyListeners();
  }

  CourseModel? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCourse(CourseModel course) async {
    _courses.add(course);
    await _save();
  }

  Future<void> updateCourse(CourseModel updatedCourse) async {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      await _save();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((c) => c.id == courseId);
    await _save();
  }

  Future<void> _save() async {
    await _storageService.saveCourses(_courses);
    notifyListeners();
  }

  void refresh() {
    _loadCourses();
  }
}

