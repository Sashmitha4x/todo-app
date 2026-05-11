import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/task_model.dart';
import 'dart:typed_data';

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

  Future<void> deleteTask(String taskId, {String? imageUrl}) async {
    String url = '${ApiConstants.baseUrl}?taskId=$taskId';
    // Append the image URL so Lambda knows to delete it from S3
    if (imageUrl != null) {
      url += '&imageUrl=${Uri.encodeComponent(imageUrl)}';
    }

    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Failed to delete task');
  }

  Future<void> updateTaskTitleAndImage(
    String taskId,
    String title, {
    String? newImageUrl,
    bool removeImage = false,
    String? oldImageUrl,
  }) async {
    final Map<String, dynamic> body = {'taskId': taskId, 'title': title};
    if (newImageUrl != null) body['imageUrl'] = newImageUrl;
    if (removeImage) body['removeImage'] = true;
    if (oldImageUrl != null) body['oldImageUrl'] = oldImageUrl;

    final response = await http.put(
      Uri.parse(ApiConstants.baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode != 200) throw Exception('Failed to update task');
  }

  Future<String?> uploadImageToS3(Uint8List imageBytes) async {
    // 1. Get Presigned URL
    final urlResponse = await http.get(
      Uri.parse('${ApiConstants.baseUrl}?action=getUploadUrl'),
    );
    if (urlResponse.statusCode != 200) return null;

    final urlData = json.decode(urlResponse.body);
    final String uploadUrl = urlData['uploadUrl'];
    final String finalImageUrl = urlData['imageUrl'];

    // 2. Upload file directly to S3
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': 'image/jpeg'},
      body: imageBytes,
    );

    if (uploadResponse.statusCode == 200) {
      return finalImageUrl;
    }
    return null;
  }
}
