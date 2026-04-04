import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskly/app/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggleStatus;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/task/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              decoration: task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.status == TaskStatus.done
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          _buildDeadlineBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriorityChip(),
                        const Spacer(),
                        if (task.dueDate != null && task.status != TaskStatus.done) _buildTimeProgress(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCheckbox() {
    bool isDone = task.status == TaskStatus.done;
    
    Color borderColor = Colors.grey.shade400;
    Color bgColor = Colors.transparent;
    Widget? child;

    if (isDone) {
      borderColor = AppColors.success;
      bgColor = AppColors.success;
      child = const Icon(Icons.check, size: 16, color: Colors.white);
    }

    return GestureDetector(
      onTap: onToggleStatus,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          color: bgColor,
        ),
        child: child,
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    switch (task.priority) {
      case TaskPriority.high:
        color = AppColors.error;
        break;
      case TaskPriority.medium:
        color = AppColors.warning;
        break;
      case TaskPriority.low:
        color = AppColors.primary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            task.priority.name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBadge() {
    final dueDate = task.dueDate!;
    
    Color color = AppColors.primary;
    String text = DateFormat('MMM d').format(dueDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeProgress() {
    final now = DateTime.now();
    final createdDay = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
    final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);

    final totalDays = dueDay.difference(createdDay).inDays + 1;
    int elapsedDays;
    if (today == createdDay) {
      elapsedDays = 1;
    } else {
      elapsedDays = today.difference(createdDay).inDays;
    }
    
    final progress = totalDays <= 0 ? 1.0 : (elapsedDays / totalDays).clamp(0.0, 1.0);
    final isOverdue = today.isAfter(dueDay);

    final Color barColor = isOverdue
        ? AppColors.error
        : progress > 0.75
            ? AppColors.warning
            : AppColors.primary;

    final String label = isOverdue
        ? 'Overdue'
        : '${(progress * 100).toStringAsFixed(0)}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isOverdue ? 1.0 : progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
