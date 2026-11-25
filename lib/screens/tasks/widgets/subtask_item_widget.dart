import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../core/constants/app_colors.dart';

class SubtaskItemWidget extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const SubtaskItemWidget({
    super.key,
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: subtask.isCompleted ? AppColors.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.secondary
                      : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade400),
                  width: 1.5,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 14,
                color: subtask.isCompleted
                    ? (isDark ? AppColors.textSecondaryDark : Colors.grey.shade500)
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

