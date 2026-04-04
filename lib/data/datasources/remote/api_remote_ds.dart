import 'package:dio/dio.dart';
import 'package:taskly/data/models/api_todo_model.dart';

abstract class ApiRemoteDataSource {
  Future<List<ApiTodoModel>> fetchTodos();
}

class ApiRemoteDataSourceImpl implements ApiRemoteDataSource {
  final Dio dio;

  ApiRemoteDataSourceImpl({required this.dio}) {
    dio.options.baseUrl = 'https://dummyjson.com';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  @override
  Future<List<ApiTodoModel>> fetchTodos() async {
    try {
      final response = await dio.get('/todos');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['todos'];
        return data.map((json) => ApiTodoModel.fromJson(json)).take(10).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch API todos: $e');
    }
  }
}
