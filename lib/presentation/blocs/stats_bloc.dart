import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

abstract class StatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {}

class StatsState extends Equatable {
  final int totalTasks;
  final int todoTasks;
  final int doneTasks;
  final int overdueTasks;

  const StatsState({
    required this.totalTasks,
    required this.todoTasks,
    required this.doneTasks,
    required this.overdueTasks,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : (doneTasks / totalTasks) * 100;

  @override
  List<Object?> get props => [totalTasks, todoTasks, doneTasks, overdueTasks];
}

class StatsLoading extends StatsState {
  const StatsLoading()
    : super(totalTasks: 0, todoTasks: 0, doneTasks: 0, overdueTasks: 0);
}

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final WatchTasksUseCase watchTasksUseCase;
  StreamSubscription? _sub;

  StatsBloc({required this.watchTasksUseCase}) : super(const StatsLoading()) {
    on<LoadStats>((event, emit) {
      _sub?.cancel();
      // Listen to the task stream and update stats whenever the task list changes.
      // This ensures the stats UI represents the real-time local database state.
      _sub = watchTasksUseCase().listen((tasks) {
        if (!isClosed) add(_StatsUpdated(tasks));
      });
    });

    on<_StatsUpdated>((event, emit) {
      final tasks = event.tasks;
      final now = DateTime.now();

      int todo = 0;
      int done = 0;
      int overdue = 0;

      for (var t in tasks) {
        if (t.status == TaskStatus.todo) todo++;
        if (t.status == TaskStatus.done) done++;

        if (t.status != TaskStatus.done &&
            t.dueDate != null &&
            t.dueDate!.isBefore(now)) {
          overdue++;
        }
      }

      emit(
        StatsState(
          totalTasks: tasks.length,
          todoTasks: todo,
          doneTasks: done,
          overdueTasks: overdue,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

class _StatsUpdated extends StatsEvent {
  final List<TaskEntity> tasks;
  _StatsUpdated(this.tasks);
}
