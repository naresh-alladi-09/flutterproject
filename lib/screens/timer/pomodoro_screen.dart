import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/timer_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  void _showSelectTaskSheet(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final pendingTasks = taskProvider.allTasks.where((t) => !t.isCompleted).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Link a Task to Focus Session', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  if (timerProvider.linkedTask != null)
                    TextButton(
                      onPressed: () {
                        timerProvider.setLinkedTask(null);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Unlink'),
                    ),
                ],
              ),
              const Divider(),
              if (pendingTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No pending tasks available to link.')),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pendingTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = pendingTasks[index];
                      final isCurrent = timerProvider.linkedTask?.id == task.id;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCurrent ? AppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(task.courseName.isNotEmpty ? task.courseName : task.category),
                        trailing: isCurrent ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                        onTap: () {
                          timerProvider.setLinkedTask(task);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timerProvider = Provider.of<TimerProvider>(context);

    final modeColor = timerProvider.mode == PomodoroMode.focus
        ? AppColors.primary
        : (timerProvider.mode == PomodoroMode.shortBreak ? AppColors.secondary : AppColors.accent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Focus Timer', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            // Mode Selectors
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Focus (25m)',
                      isSelected: timerProvider.mode == PomodoroMode.focus,
                      activeColor: AppColors.primary,
                      onTap: () => timerProvider.setMode(PomodoroMode.focus),
                    ),
                  ),
                  Expanded(
                    child: _ModeButton(
                      label: 'Short (5m)',
                      isSelected: timerProvider.mode == PomodoroMode.shortBreak,
                      activeColor: AppColors.secondary,
                      onTap: () => timerProvider.setMode(PomodoroMode.shortBreak),
                    ),
                  ),
                  Expanded(
                    child: _ModeButton(
                      label: 'Long (15m)',
                      isSelected: timerProvider.mode == PomodoroMode.longBreak,
                      activeColor: AppColors.accent,
                      onTap: () => timerProvider.setMode(PomodoroMode.longBreak),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Linked Task Card
            InkWell(
              onTap: () => _showSelectTaskSheet(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: timerProvider.linkedTask != null
                        ? AppColors.primaryLight.withOpacity(0.5)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      timerProvider.linkedTask != null ? Icons.task_alt : Icons.add_task,
                      color: timerProvider.linkedTask != null ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timerProvider.linkedTask != null
                                ? 'Focusing On: ${timerProvider.linkedTask!.title}'
                                : 'Link an assignment or task to this timer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: timerProvider.linkedTask != null ? FontWeight.w700 : FontWeight.w500,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (timerProvider.linkedTask != null)
                            Text(
                              '${timerProvider.linkedTask!.completedPomodoros} of ${timerProvider.linkedTask!.estimatedPomodoros} sessions completed',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Large Circular Timer Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: timerProvider.progress,
                    strokeWidth: 14,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerProvider.formattedTime,
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timerProvider.mode == PomodoroMode.focus
                          ? 'DEEP WORK'
                          : (timerProvider.mode == PomodoroMode.shortBreak ? 'SHORT REST' : 'LONG REST'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: modeColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Session #${timerProvider.completedSessions + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: modeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Action Controls: Play/Pause, Reset, Skip
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                IconButton.filledTonal(
                  onPressed: timerProvider.reset,
                  iconSize: 24,
                  padding: const EdgeInsets.all(14),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Timer',
                ),

                const SizedBox(width: 20),

                // Main Start / Pause Button
                ElevatedButton(
                  onPressed: timerProvider.toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: modeColor,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    elevation: 6,
                    shadowColor: modeColor.withOpacity(0.4),
                  ),
                  child: Icon(
                    timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                ),

                const SizedBox(width: 20),

                // Skip Mode Button
                IconButton.filledTonal(
                  onPressed: () {
                    if (timerProvider.mode == PomodoroMode.focus) {
                      timerProvider.setMode(PomodoroMode.shortBreak);
                    } else {
                      timerProvider.setMode(PomodoroMode.focus);
                    }
                  },
                  iconSize: 24,
                  padding: const EdgeInsets.all(14),
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Skip to Next',
                ),
              ],
            ),

            const SizedBox(height: 36),

            // Ambient Sound Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.graphic_eq, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Study Soundscape', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      if (timerProvider.selectedAmbientSound != 'Off')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timerProvider.availableAmbientSounds.map((sound) {
                      final isSelected = timerProvider.selectedAmbientSound == sound;
                      return ChoiceChip(
                        label: Text(sound),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (_) => timerProvider.setAmbientSound(sound),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Study Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Today\'s Study', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '${timerProvider.totalStudyMinutesToday} mins',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
                  Column(
                    children: [
                      const Text('Completed Cycles', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '${timerProvider.completedSessions} sessions',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

