import 'package:flutter/material.dart';
import 'package:taskly/app/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskStatus? currentFilter;
  final ValueChanged<TaskStatus?> onFilterChanged;

  const TaskFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChip('All', null),
          const SizedBox(width: 12),
          _buildChip('To Do', TaskStatus.todo),
          const SizedBox(width: 12),
          _buildChip('Done', TaskStatus.done),
        ],
      ),
    );
  }

  Widget _buildChip(String label, TaskStatus? value) {
    final isSelected = currentFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey.shade200,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
