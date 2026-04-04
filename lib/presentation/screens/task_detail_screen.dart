import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskly/app/theme/app_colors.dart';
import '../blocs/task_list_bloc.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          BlocBuilder<TaskListBloc, TaskListState>(
            builder: (context, state) {
               if (state is TaskListLoaded) {
                 final taskList = state.allTasks.where((t) => t.id == taskId).toList();
                 if (taskList.isNotEmpty) {
                    final task = taskList.first;
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push('/task/${task.id}/edit', extra: task);
                      },
                    );
                 }
               }
               return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          if (state is TaskListLoaded) {
            final taskList = state.allTasks.where((t) => t.id == taskId).toList();
            if (taskList.isEmpty) {
              return const Center(child: Text('Task not found.'));
            }
            final task = taskList.first;
            final dateFormat = DateFormat('MMM d, yyyy');

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(task.description, style: const TextStyle(fontSize: 16, color:  AppColors.textSecondaryDark)),
                  const SizedBox(height: 24),
                  _buildInfoRow('Status', task.status.name.toUpperCase()),
                  _buildInfoRow('Priority', task.priority.name.toUpperCase()),
                  _buildInfoRow('Created', dateFormat.format(task.createdAt)),
                  _buildInfoRow('Due to', task.dueDate != null ? dateFormat.format(task.dueDate!) : 'None'),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
