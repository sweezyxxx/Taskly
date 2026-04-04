import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

// --- Events ---
abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();
  @override List<Object?> get props => [];
}

class SaveTaskEvent extends TaskDetailEvent {
  final TaskEntity task;
  final bool isEditing;
  const SaveTaskEvent(this.task, {this.isEditing = false});
  @override List<Object?> get props => [task, isEditing];
}

// --- States ---
abstract class TaskDetailState extends Equatable {
  const TaskDetailState();
  @override List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {}

class TaskDetailSaving extends TaskDetailState {}

class TaskDetailSuccess extends TaskDetailState {}

class TaskDetailError extends TaskDetailState {
  final String message;
  const TaskDetailError(this.message);
  @override List<Object?> get props => [message];
}

// --- BLoC ---
class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final CreateTaskUseCase createUseCase;
  final UpdateTaskUseCase updateUseCase;

  TaskDetailBloc({
    required this.createUseCase,
    required this.updateUseCase,
  }) : super(TaskDetailInitial()) {
    on<SaveTaskEvent>(_onSaveTask);
  }

  Future<void> _onSaveTask(SaveTaskEvent event, Emitter<TaskDetailState> emit) async {
    emit(TaskDetailSaving());
    try {
      if (event.isEditing) {
        await updateUseCase(event.task);
      } else {
        await createUseCase(event.task);
      }
      emit(TaskDetailSuccess());
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }
}
