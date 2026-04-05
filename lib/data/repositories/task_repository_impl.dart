import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_ds.dart';
import '../datasources/remote/task_remote_ds.dart';
import '../datasources/remote/api_remote_ds.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

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
    _pushToCloud(model); // Run asynchronously without awaiting so UI isn't blocked
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
    } catch (_) {
      // If we are offline, the cloud deletion fails but local deletion succeeded.
      // A more robust implementation might queue deletions.
    }
  }

  @override
  Future<void> syncWithCloud() async {
    // 1. Send all unsynced local tasks to the cloud
    final unsynced = await localDs.getUnsyncedTasks();

    for (final task in unsynced) {
      try {
        await remoteDs.pushTask(task);
        await localDs.markAsSynced(task.id);
      } catch (_) {
        // If pushing fails, the task remains unsynced for future attempts
      }
    }

    // 2. Fetch the latest remote data from the cloud
    try {
      final remoteTasks = await remoteDs.watchRemoteTasks().first;

      // 3. Merge remote tasks into the local database (upsert updates existing or inserts new)
      for (final task in remoteTasks) {
        await localDs.upsertTask(task);
      }
    } catch (_) {
      // Ignore errors if the device is currently offline
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
    } catch (_) {
      // If push fails, it will remain unsynced and retry on the next manual sync
    }
  }

  @override
  Future<void> clearLocalData() async {
    await localDs.clearAllTasks();
    _isRealtimeStarted = false; // Reset realtime sync flag so the next user can initiate their own sync process
  }
}
