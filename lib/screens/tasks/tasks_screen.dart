import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_sheet.dart';
import 'task_detail_screen.dart';
import 'add_edit_task_screen.dart';
import '../../widgets/empty_state_view.dart';

class TasksScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const TasksScreen({super.key, this.onNavigateTab});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Today', 'Upcoming', 'Completed', 'Overdue'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final timerProvider = Provider.of<TimerProvider>(context);
    final tasks = taskProvider.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Academic Tasks', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Filter & Sort',
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (taskProvider.selectedCourseFilter != null || taskProvider.selectedPriorityFilter != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const TaskFilterSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => taskProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search tasks, subjects, notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          taskProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Horizontal Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = taskProvider.selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => taskProvider.setFilter(filter),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Active Filters summary row if applied
          if (taskProvider.selectedCourseFilter != null || taskProvider.selectedPriorityFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Filters: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  if (taskProvider.selectedPriorityFilter != null) ...[
                    Chip(
                      label: Text(taskProvider.selectedPriorityFilter!),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => taskProvider.setPriorityFilter(null),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (taskProvider.selectedCourseFilter != null) ...[
                    Chip(
                      label: const Text('Course Filter'),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => taskProvider.setCourseFilter(null),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => taskProvider.clearFilters(),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? EmptyStateView(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'No tasks found',
                    message: taskProvider.searchQuery.isNotEmpty
                        ? 'No tasks match "${taskProvider.searchQuery}". Try different keywords.'
                        : 'No tasks in "${taskProvider.selectedFilter}". Tap below to create your next assignment!',
                    buttonText: 'Add New Task',
                    onButtonPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                        onToggleComplete: () => taskProvider.toggleTaskCompletion(task.id),
                        onDelete: () => taskProvider.deleteTask(task.id),
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(taskToEdit: task),
                            ),
                          );
                        },
                        onFocus: () {
                          timerProvider.setLinkedTask(task);
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(3); // Pomodoro tab
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

