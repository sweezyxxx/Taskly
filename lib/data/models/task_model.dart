import 'package:drift/drift.dart';

import '../../domain/entities/task_entity.dart';
import '../database/app_database.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    required super.isSynced,
  });

  // Creates a TaskModel from a Firestore document. 
  // The ID is passed separately since it corresponds to the document ID in Firestore.
  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String).toLocal()
          : null,

      // Since this data was just fetched from the cloud, it is definitively synced.
      isSynced: true,
    );
  }

  // Serializes the TaskModel to a format suitable for Firestore. 
  // The isSynced flag is omitted as it is a local-only tracking concept.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromDrift(Task driftTask) {
    return TaskModel(
      id: driftTask.id,
      title: driftTask.title,
      description: driftTask.description,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == driftTask.status,
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == driftTask.priority,
        orElse: () => TaskPriority.medium,
      ),
      createdAt: driftTask.createdAt,
      updatedAt: driftTask.updatedAt,
      dueDate: driftTask.dueDate,
      isSynced: driftTask.isSynced,
    );
  }

  TasksCompanion toDriftCompanion() {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      status: Value(status.name),
      priority: Value(priority.name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dueDate: Value(dueDate),
      isSynced: Value(isSynced),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    bool? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
