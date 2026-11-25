import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/course_provider.dart';

class TaskFilterSheet extends StatelessWidget {
  const TaskFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {
                  taskProvider.clearFilters();
                  Navigator.of(context).pop();
                },
                child: const Text('Reset All', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Priority Filter
          const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Urgent', 'High', 'Medium', 'Low'].map((p) {
              final isSelected = taskProvider.selectedPriorityFilter?.toLowerCase() == p.toLowerCase();
              return ChoiceChip(
                label: Text(p),
                selected: isSelected,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (selected) {
                  taskProvider.setPriorityFilter(selected ? p : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Course Filter
          const Text('Course', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: courseProvider.courses.map((course) {
              final isSelected = taskProvider.selectedCourseFilter == course.id;
              return ChoiceChip(
                label: Text(course.code),
                selected: isSelected,
                selectedColor: Color(course.colorValue).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Color(course.colorValue) : null,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (selected) {
                  taskProvider.setCourseFilter(selected ? course.id : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Sort By
          const Text('Sort By', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Due Date (Earliest)'),
                selected: taskProvider.sortOption == TaskSortOption.dueDateAsc,
                onSelected: (_) => taskProvider.setSortOption(TaskSortOption.dueDateAsc),
              ),
              ChoiceChip(
                label: const Text('Priority'),
                selected: taskProvider.sortOption == TaskSortOption.priority,
                onSelected: (_) => taskProvider.setSortOption(TaskSortOption.priority),
              ),
              ChoiceChip(
                label: const Text('Title (A-Z)'),
                selected: taskProvider.sortOption == TaskSortOption.title,
                onSelected: (_) => taskProvider.setSortOption(TaskSortOption.title),
              ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

