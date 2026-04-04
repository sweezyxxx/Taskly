import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class WatchTasksUseCase {
  final TaskRepository repository;
  WatchTasksUseCase(this.repository);
  Stream<List<TaskEntity>> call() => repository.watchTasks();
}

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);
  Future<void> call(TaskEntity task) => repository.createTask(task);
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);
  Future<void> call(TaskEntity task) => repository.updateTask(task);
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);
  Future<void> call(String id) => repository.deleteTask(id);
}

class SyncTasksUseCase {
  final TaskRepository repository;
  SyncTasksUseCase(this.repository);
  /// Synchronizes local and remote tasks
  Future<void> call() => repository.syncWithCloud();
}

class ImportTasksUseCase {
  final TaskRepository repository;
  ImportTasksUseCase(this.repository);
  Future<void> call() => repository.importSampleTasks();
}
