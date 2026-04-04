import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchTasks();
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> syncWithCloud();
  Future<void> importSampleTasks();
  void startRealtimeSync();
  Future<void> clearLocalData();
}
