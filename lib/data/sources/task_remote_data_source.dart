import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  Future<List<TaskModel>> fetchTasks() async {
    final response = await http.get(Uri.parse(ApiConstants.baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return TaskModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(String taskId, bool isCompleted) async {
    final response = await http.put(
      Uri.parse(ApiConstants.baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'taskId': taskId, 'isCompleted': isCompleted}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}?taskId=$taskId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<void> updateTaskTitle(String taskId, String newTitle) async {
    final response = await http.put(
      Uri.parse(ApiConstants.baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'taskId': taskId, 'title': newTitle}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task title');
    }
  }
}
