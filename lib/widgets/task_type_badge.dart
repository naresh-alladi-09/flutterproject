import 'package:flutter/material.dart';

class TaskTypeBadge extends StatelessWidget {
  final String category;

  const TaskTypeBadge({super.key, required this.category});

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'assignment':
        return Icons.assignment_outlined;
      case 'exam prep':
      case 'exam':
        return Icons.school_outlined;
      case 'project':
        return Icons.folder_outlined;
      case 'homework':
        return Icons.edit_note_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'personal':
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    switch (category.toLowerCase()) {
      case 'assignment':
        return const Color(0xFF6366F1);
      case 'exam prep':
      case 'exam':
        return const Color(0xFFEF4444);
      case 'project':
        return const Color(0xFF06B6D4);
      case 'homework':
        return const Color(0xFF10B981);
      case 'reading':
        return const Color(0xFF8B5CF6);
      case 'personal':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(), size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

