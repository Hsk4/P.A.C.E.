// lib/core/services/network_service.dart
import 'package:dio/dio.dart';
import '../../models/task_model.dart';

class NetworkService {
  // Replace this placeholder string with the custom domain provided by your Railway dashboard
 static const String _baseUrl = 'https://pace-backend.onrender.com';
  
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10), // Terminate slow handshakes
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // === FETCH ALL TASKS (GET) ===
  static Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await _dio.get('/tasks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('Network Error fetching tasks: $e');
      return []; // Return empty array or cache fallbacks on network drop
    }
  }

  // === CREATE NEW TASK (POST) ===
  static Future<TaskModel?> saveTask(TaskModel task) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: task.toJson(),
      );
      if (response.statusCode == 201) {
        return TaskModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Network Error creating task: $e');
      return null;
    }
  }
}
