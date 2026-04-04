class ApiTodoModel {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const ApiTodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory ApiTodoModel.fromJson(Map<String, dynamic> json) {
    return ApiTodoModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: (json['title'] ?? json['todo'] ?? 'Untitled') as String,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed,
    };
  }
}
