import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_ds.dart';
import '../datasources/remote/task_remote_ds.dart';
import '../datasources/remote/api_remote_ds.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/logger.dart';

class TaskRepositoryImpl implements TaskRepository {
  bool _isRealtimeStarted = false;
  final TaskLocalDataSource localDs;
  final TaskRemoteDataSource remoteDs;
  final ApiRemoteDataSource apiDs;

  TaskRepositoryImpl({
    required this.localDs,
    required this.remoteDs,
    required this.apiDs,
  });

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return localDs.watchTasks();
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      dueDate: task.dueDate,
      isSynced: false,
    );
    await localDs.insertTask(model);
    _pushToCloud(model); // fire and forget
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
      dueDate: task.dueDate,
      isSynced: false,
    );
    await localDs.updateTask(model);
    _pushToCloud(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDs.deleteTask(id);
    try {
      await remoteDs.deleteRemoteTask(id);
      appLogger.i('Deleted remote task: $id');
    } catch (e, stackTrace) {
      appLogger.w('Offline fallback for deleting task $id', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> syncWithCloud() async {
    /// 1. отправляем НЕ синкнутые задачи
    final unsynced = await localDs.getUnsyncedTasks();

    for (final task in unsynced) {
      try {
        await remoteDs.pushTask(task);
        await localDs.markAsSynced(task.id);
        appLogger.i('Synced local task to remote: ${task.id}');
      } catch (e, stackTrace) {
        appLogger.w('Failed to push task ${task.id} to cloud (Offline?)', error: e, stackTrace: stackTrace);
      }
    }

    /// 2. получаем remote данные
    try {
      final remoteTasks = await remoteDs.watchRemoteTasks().first;

      /// 3. merge в local
      for (final task in remoteTasks) {
        await localDs.upsertTask(task);
      }
      appLogger.i('Successfully merged remote tasks into local storage.');
    } catch (e, stackTrace) {
      appLogger.w('Failed to fetch remote tasks (Offline?)', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> importSampleTasks() async {
    final todos = await apiDs.fetchTodos();
    const uuid = Uuid();
    for (var apiTodo in todos) {
      final task = TaskModel(
        id: uuid.v4(),
        title: apiTodo.title,
        description: 'Imported from API',
        status: apiTodo.completed ? TaskStatus.done : TaskStatus.todo,
        priority: TaskPriority.low,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: null,
        isSynced: false,
      );
      await localDs.insertTask(task);
    }
  }
  
  @override
  void startRealtimeSync() {
    if (_isRealtimeStarted) return;
    _isRealtimeStarted = true;

    remoteDs.watchRemoteTasks().listen((remoteTasks) async {
      for (final task in remoteTasks) {
        await localDs.upsertTask(task);
      }
    });
  }

  Future<void> _pushToCloud(TaskModel task) async {
    try {
      await remoteDs.pushTask(task);
      await localDs.markAsSynced(task.id);
      appLogger.i('Pushed local task to remote: ${task.id}');
    } catch (e, stackTrace) {
      appLogger.w('Failed to push task to remote immediately', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> clearLocalData() async {
    await localDs.clearAllTasks();
    _isRealtimeStarted = false; // allow restarting sync for new user
  }
}
