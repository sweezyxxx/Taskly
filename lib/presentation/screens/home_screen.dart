import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskly/app/theme/app_colors.dart';

import '../../domain/entities/task_entity.dart';
import '../blocs/settings_bloc.dart';
import '../blocs/task_list_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/statistics'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<TaskListBloc, TaskListState>(
            builder: (context, state) {
              if (state is TaskListLoaded) {
                return TaskFilterBar(
                  currentFilter: state.currentFilter,
                  onFilterChanged: (filter) {
                    context.read<TaskListBloc>().add(FilterTasks(filter));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<TaskListBloc, TaskListState>(
              builder: (context, state) {
                if (state is TaskListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskListError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is TaskListLoaded) {
                  final tasks = state.filteredTasks;
                  if (tasks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SettingsBloc>().add(SyncData());
                    },
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            context.read<TaskListBloc>().add(
                              DeleteTaskEvent(task.id),
                            );
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Task deleted',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(milliseconds: 800),
                                ),
                              );
                          },
                          child: TaskCard(
                            task: task,
                            onToggleStatus: () {
                              TaskStatus newStatus;
                              if (task.status == TaskStatus.todo) {
                                newStatus = TaskStatus.done;
                              } else {
                                newStatus = TaskStatus.todo;
                              }

                              context.read<TaskListBloc>().add(
                                UpdateTaskStatusEvent(task, newStatus),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary.withValues(alpha: 0.6),
        onPressed: () => context.push('/task/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 80,
            color: Colors.grey.shade300,
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            'No tasks here yet!',
            style: GoogleFonts.outfit(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
