import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/course_provider.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/note_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Local Storage Service
  final storageService = StorageService();
  await storageService.init();

  runApp(StudyFlowApp(storageService: storageService));
}

class StudyFlowApp extends StatelessWidget {
  final StorageService storageService;

  const StudyFlowApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) => CourseProvider(storageService),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(storageService),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider(storageService),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (_) => NoteProvider(storageService),
        ),
        ChangeNotifierProxyProvider<TaskProvider, TimerProvider>(
          create: (_) => TimerProvider(storageService),
          update: (_, taskProvider, timerProvider) {
            timerProvider?.updateTaskProvider(taskProvider);
            return timerProvider ?? TimerProvider(storageService);
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StudyFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: MainNavigationScreen(storageService: storageService),
          );
        },
      ),
    );
  }
}

