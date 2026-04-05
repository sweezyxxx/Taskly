import 'dart:async';
import 'package:drift/drift.dart';
import 'package:taskly/data/database/app_database.dart';
import 'package:taskly/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Stream<List<TaskModel>> watchTasks();
  Future<List<TaskModel>> getAllTasks();
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void> markAsSynced(String id);
  Future<void> upsertTask(TaskModel task);
  Future<void> clearAllTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase db;

  TaskLocalDataSourceImpl({required this.db});

  @override
  Stream<List<TaskModel>> watchTasks() {
    return db
        .select(db.tasks)
        .watch()
        .map((rows) => rows.map(TaskModel.fromDrift).toList());
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final rows = await db.select(db.tasks).get();
    return rows.map(TaskModel.fromDrift).toList();
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    await db.into(db.tasks).insert(task.toDriftCompanion());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await db.update(db.tasks).replace(task.toDriftCompanion());
  }

  @override
  Future<void> deleteTask(String id) async {
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
  }

  // Retrieves tasks that have not yet been synchronized with the cloud backend.
  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final rows = await (db.select(
      db.tasks,
    )..where((t) => t.isSynced.equals(false))).get();

    return rows.map(TaskModel.fromDrift).toList();
  }

  // Marks a specific task as successfully synchronized with the cloud.
  @override
  Future<void> markAsSynced(String id) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(isSynced: const Value(true)),
    );
  }

  // Inserts a new task or updates it if it already exists, ensuring it is marked as synced. 
  // This is the core method for merging remote data locally without conflicts.
  @override
  Future<void> upsertTask(TaskModel task) async {
    await db
        .into(db.tasks)
        .insertOnConflictUpdate(
          task.copyWith(isSynced: true).toDriftCompanion(),
        );
  }

  // Clears the entire local database. Typically called during logout to prevent data leaks between different users.
  @override
  Future<void> clearAllTasks() async {
    await db.delete(db.tasks).go();
  }
}
