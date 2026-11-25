import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../models/task_model.dart';
import 'task_provider.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  final StorageService _storageService;
  TaskProvider? _taskProvider;

  PomodoroMode _mode = PomodoroMode.focus;
  int _focusDurationMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;

  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;

  int _completedSessions = 0;
  int _totalStudyMinutesToday = 0;
  TaskModel? _linkedTask;
  String _selectedAmbientSound = 'Off'; // Off, Rain, Cafe, White Noise, Forest

  final List<String> availableAmbientSounds = [
    'Off',
    'Gentle Rain 🌧️',
    'Campus Library 📚',
    'Coffee Shop ☕',
    'White Noise 🍃',
  ];

  TimerProvider(this._storageService) {
    _remainingSeconds = _focusDurationMinutes * 60;
    _totalStudyMinutesToday = _storageService.getStudyMinutes();
  }

  void updateTaskProvider(TaskProvider taskProvider) {
    _taskProvider = taskProvider;
  }

  PomodoroMode get mode => _mode;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  int get completedSessions => _completedSessions;
  int get totalStudyMinutesToday => _totalStudyMinutesToday;
  TaskModel? get linkedTask => _linkedTask;
  String get selectedAmbientSound => _selectedAmbientSound;
  int get currentTotalDurationSeconds {
    switch (_mode) {
      case PomodoroMode.focus:
        return _focusDurationMinutes * 60;
      case PomodoroMode.shortBreak:
        return _shortBreakMinutes * 60;
      case PomodoroMode.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  double get progress {
    final total = currentTotalDurationSeconds;
    if (total == 0) return 0.0;
    return (_remainingSeconds / total).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setLinkedTask(TaskModel? task) {
    _linkedTask = task;
    notifyListeners();
  }

  void setAmbientSound(String sound) {
    _selectedAmbientSound = sound;
    notifyListeners();
  }

  void setCustomFocusDuration(int minutes) {
    _focusDurationMinutes = minutes;
    if (_mode == PomodoroMode.focus && !_isRunning) {
      _remainingSeconds = minutes * 60;
    }
    notifyListeners();
  }

  void setMode(PomodoroMode newMode) {
    pause();
    _mode = newMode;
    switch (_mode) {
      case PomodoroMode.focus:
        _remainingSeconds = _focusDurationMinutes * 60;
        break;
      case PomodoroMode.shortBreak:
        _remainingSeconds = _shortBreakMinutes * 60;
        break;
      case PomodoroMode.longBreak:
        _remainingSeconds = _longBreakMinutes * 60;
        break;
    }
    notifyListeners();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onSessionComplete();
      }
    });
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void toggle() {
    if (_isRunning) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    pause();
    switch (_mode) {
      case PomodoroMode.focus:
        _remainingSeconds = _focusDurationMinutes * 60;
        break;
      case PomodoroMode.shortBreak:
        _remainingSeconds = _shortBreakMinutes * 60;
        break;
      case PomodoroMode.longBreak:
        _remainingSeconds = _longBreakMinutes * 60;
        break;
    }
    notifyListeners();
  }

  Future<void> _onSessionComplete() async {
    pause();

    if (_mode == PomodoroMode.focus) {
      _completedSessions++;
      final sessionMins = _focusDurationMinutes;
      _totalStudyMinutesToday += sessionMins;
      await _storageService.addStudyMinutes(sessionMins);

      if (_linkedTask != null && _taskProvider != null) {
        await _taskProvider!.incrementCompletedPomodoro(_linkedTask!.id);
        // Refresh linked task reference
        _linkedTask = _taskProvider!.getTaskById(_linkedTask!.id);
      }

      // Switch to break
      if (_completedSessions % 4 == 0) {
        setMode(PomodoroMode.longBreak);
      } else {
        setMode(PomodoroMode.shortBreak);
      }
    } else {
      // Break finished, switch back to focus
      setMode(PomodoroMode.focus);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

