import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../core/services/storage_service.dart';

class ScheduleProvider with ChangeNotifier {
  final StorageService _storageService;
  List<ScheduleModel> _schedules = [];
  int _selectedDay = DateTime.now().weekday; // 1 = Monday, 7 = Sunday

  ScheduleProvider(this._storageService) {
    _loadSchedules();
  }

  List<ScheduleModel> get schedules => _schedules;
  int get selectedDay => _selectedDay;

  void _loadSchedules() {
    _schedules = _storageService.loadSchedules();
    notifyListeners();
  }

  void setSelectedDay(int day) {
    _selectedDay = day;
    notifyListeners();
  }

  List<ScheduleModel> get schedulesForSelectedDay {
    final list = _schedules.where((s) => s.dayOfWeek == _selectedDay).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  List<ScheduleModel> getSchedulesForDay(int dayOfWeek) {
    final list = _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    _schedules.add(schedule);
    await _save();
  }

  Future<void> updateSchedule(ScheduleModel updatedSchedule) async {
    final index = _schedules.indexWhere((s) => s.id == updatedSchedule.id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      await _save();
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    await _save();
  }

  Future<void> _save() async {
    await _storageService.saveSchedules(_schedules);
    notifyListeners();
  }

  void refresh() {
    _loadSchedules();
  }
}

