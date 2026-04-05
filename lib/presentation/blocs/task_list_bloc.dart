import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskListEvent {}

class FilterTasks extends TaskListEvent {
  final TaskStatus? statusFilter;
  const FilterTasks(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

class DeleteTaskEvent extends TaskListEvent {
  final String taskId;
  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskStatusEvent extends TaskListEvent {
  final TaskEntity task;
  final TaskStatus newStatus;

  const UpdateTaskStatusEvent(this.task, this.newStatus);

  @override
  List<Object?> get props => [task, newStatus];
}

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListLoading extends TaskListState {}

class TaskListLoaded extends TaskListState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatus? currentFilter;

  const TaskListLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [allTasks, filteredTasks, currentFilter];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}

class _TasksUpdated extends TaskListEvent {
  final List<TaskEntity> tasks;

  const _TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final WatchTasksUseCase watchTasksUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  StreamSubscription? _tasksSubscription;

  TaskListBloc({
    required this.watchTasksUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskListLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<_TasksUpdated>(_onTasksUpdated);
    on<FilterTasks>(_onFilterTasks);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskStatusEvent>(_onUpdateStatus);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskListState> emit) {
    _tasksSubscription?.cancel();

    _tasksSubscription = watchTasksUseCase().listen((tasks) {
      if (!isClosed) {
        add(_TasksUpdated(tasks));
      }
    });
  }

  void _onTasksUpdated(_TasksUpdated event, Emitter<TaskListState> emit) {
    final currentFilter = state is TaskListLoaded
        ? (state as TaskListLoaded).currentFilter
        : null;

    emit(
      TaskListLoaded(
        allTasks: event.tasks,
        filteredTasks: _applyFilter(event.tasks, currentFilter),
        currentFilter: currentFilter,
      ),
    );
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskListState> emit) {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      emit(
        TaskListLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: _applyFilter(
            currentState.allTasks,
            event.statusFilter,
          ),
          currentFilter: event.statusFilter,
        ),
      );
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskListState> emit,
  ) async {
    await deleteTaskUseCase(event.taskId);
  }

  Future<void> _onUpdateStatus(
    UpdateTaskStatusEvent event,
    Emitter<TaskListState> emit,
  ) async {
    final updatedTask = TaskEntity(
      id: event.task.id,
      title: event.task.title,
      description: event.task.description,
      status: event.newStatus,
      priority: event.task.priority,
      createdAt: event.task.createdAt,
      updatedAt: DateTime.now(),
      dueDate: event.task.dueDate,
      isSynced: false,
    );

    await updateTaskUseCase(updatedTask);
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}

List<TaskEntity> _applyFilter(List<TaskEntity> tasks, TaskStatus? filter) {
  if (filter == null) return tasks;
  return tasks.where((t) => t.status == filter).toList();
}
