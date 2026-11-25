import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/course_provider.dart';
import '../../providers/task_provider.dart';
import 'course_detail_screen.dart';
import 'add_edit_course_dialog.dart';
import '../../widgets/empty_state_view.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseProvider = Provider.of<CourseProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses & Subjects', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Add Course',
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () async {
              final newCourse = await showDialog<CourseModel>(
                context: context,
                builder: (_) => const AddEditCourseDialog(),
              );
              if (newCourse != null) {
                await courseProvider.addCourse(newCourse);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newCourse = await showDialog<CourseModel>(
            context: context,
            builder: (_) => const AddEditCourseDialog(),
          );
          if (newCourse != null) {
            await courseProvider.addCourse(newCourse);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: courses.isEmpty
          ? EmptyStateView(
              icon: Icons.school_outlined,
              title: 'No courses added yet',
              message: 'Add your semester subjects to categorize tasks, assignments, and schedule your classes.',
              buttonText: 'Add First Course',
              onButtonPressed: () async {
                final newCourse = await showDialog<CourseModel>(
                  context: context,
                  builder: (_) => const AddEditCourseDialog(),
                );
                if (newCourse != null) {
                  await courseProvider.addCourse(newCourse);
                }
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                final tasks = taskProvider.getTasksForCourse(course.id);
                final pendingCount = tasks.where((t) => !t.isCompleted).length;
                final completedCount = tasks.where((t) => t.isCompleted).length;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(courseId: course.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(course.colorValue).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.school,
                              color: Color(course.colorValue),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(course.colorValue).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      course.code,
                                      style: TextStyle(
                                        color: Color(course.colorValue),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  if (course.room.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      course.room,
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                course.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              if (course.instructor.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  course.instructor,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '$pendingCount pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: pendingCount > 0 ? AppColors.warning : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• $completedCount done',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

