import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import 'add_class_dialog.dart';
import '../../widgets/empty_state_view.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  final List<Map<String, dynamic>> _weekdays = const [
    {'day': 1, 'short': 'Mon', 'full': 'Monday'},
    {'day': 2, 'short': 'Tue', 'full': 'Tuesday'},
    {'day': 3, 'short': 'Wed', 'full': 'Wednesday'},
    {'day': 4, 'short': 'Thu', 'full': 'Thursday'},
    {'day': 5, 'short': 'Fri', 'full': 'Friday'},
    {'day': 6, 'short': 'Sat', 'full': 'Saturday'},
    {'day': 7, 'short': 'Sun', 'full': 'Sunday'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final selectedDay = scheduleProvider.selectedDay;
    final dayClasses = scheduleProvider.schedulesForSelectedDay;

    final selectedDayName =
        _weekdays.firstWhere((d) => d['day'] == selectedDay)['full'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Add Class',
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () async {
              final newSched = await showDialog<ScheduleModel>(
                context: context,
                builder: (_) => AddClassDialog(initialDayOfWeek: selectedDay),
              );
              if (newSched != null) {
                await scheduleProvider.addSchedule(newSched);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newSched = await showDialog<ScheduleModel>(
            context: context,
            builder: (_) => AddClassDialog(initialDayOfWeek: selectedDay),
          );
          if (newSched != null) {
            await scheduleProvider.addSchedule(newSched);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Class', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Weekday selector strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weekdays.map((item) {
                final day = item['day'] as int;
                final short = item['short'] as String;
                final isSelected = day == selectedDay;

                return InkWell(
                  onTap: () => scheduleProvider.setSelectedDay(day),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          short,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : (scheduleProvider.getSchedulesForDay(day).isNotEmpty
                                    ? AppColors.primaryLight
                                    : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Day header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedDayName Schedule',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${dayClasses.length} ${dayClasses.length == 1 ? "Class" : "Classes"}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Classes List
          Expanded(
            child: dayClasses.isEmpty
                ? EmptyStateView(
                    icon: Icons.event_busy_outlined,
                    title: 'No classes on $selectedDayName',
                    message: 'You have no scheduled lectures or lab periods for this day.',
                    buttonText: 'Add Class',
                    onButtonPressed: () async {
                      final newSched = await showDialog<ScheduleModel>(
                        context: context,
                        builder: (_) => AddClassDialog(initialDayOfWeek: selectedDay),
                      );
                      if (newSched != null) {
                        await scheduleProvider.addSchedule(newSched);
                      }
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: dayClasses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final schedule = dayClasses[index];

                      return Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Color Accent Pill
                            Container(
                              width: 5,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(schedule.colorValue),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Main Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          schedule.courseName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(schedule.colorValue).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${schedule.startTime} - ${schedule.endTime}',
                                          style: TextStyle(
                                            color: Color(schedule.colorValue),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (schedule.room.isNotEmpty) ...[
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          schedule.room,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      if (schedule.instructor.isNotEmpty) ...[
                                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            schedule.instructor,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Action Menu
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  final updated = await showDialog<ScheduleModel>(
                                    context: context,
                                    builder: (_) => AddClassDialog(
                                      initialDayOfWeek: selectedDay,
                                      scheduleToEdit: schedule,
                                    ),
                                  );
                                  if (updated != null) {
                                    await scheduleProvider.updateSchedule(updated);
                                  }
                                } else if (val == 'delete') {
                                  await scheduleProvider.deleteSchedule(schedule.id);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Class'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: AppColors.danger)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

