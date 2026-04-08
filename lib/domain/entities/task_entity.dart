import 'package:equatable/equatable.dart';

enum TaskStatus { todo, done }

enum TaskPriority { low, medium, high }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final bool isSynced;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    required this.isSynced,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    createdAt,
    updatedAt,
    dueDate,
    isSynced,
  ];
}
