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
    return db.select(db.tasks).watch().map(
      (rows) => rows.map(TaskModel.fromDrift).toList(),
    );
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

  /// 🔥 НЕ синкнутые задачи
  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final rows = await (db.select(db.tasks)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    return rows.map(TaskModel.fromDrift).toList();
  }

  /// 🔥 пометить как synced
  @override
  Future<void> markAsSynced(String id) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isSynced: const Value(true),
      ),
    );
  }

  /// 🔥 главный метод для merge
  @override
  Future<void> upsertTask(TaskModel task) async {
    await db.into(db.tasks).insertOnConflictUpdate(
      task.copyWith(isSynced: true).toDriftCompanion(),
    );
  }

  /// 🔥 очистить все при выходе из аккаунта
  @override
  Future<void> clearAllTasks() async {
    await db.delete(db.tasks).go();
  }
}