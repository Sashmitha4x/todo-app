import 'package:dil_pickle_todo/data/repositories/task_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import 'dart:typed_data';

class TaskProvider with ChangeNotifier {
  final TaskRepository repository;

  List<TaskEntity> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  TaskProvider({required this.repository}) {
    fetchTasks();
  }

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _setLoading(true);
    try {
      _tasks = await repository.getTasks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addTask(String title, {Uint8List? imageBytes}) async {
    if (title.trim().isEmpty) return;
    _setLoading(true);

    String? uploadedImageUrl;

    try {
      // If an image was picked, upload it FIRST
      if (imageBytes != null) {
        uploadedImageUrl = await (repository as TaskRepositoryImpl)
            .remoteDataSource
            .uploadImageToS3(imageBytes);
      }

      final newTask = TaskEntity(
        taskId: const Uuid().v4(),
        title: title.trim(),
        imageUrl: uploadedImageUrl, // Attach the URL
        createdAt: DateTime.now().toIso8601String(),
      );

      _tasks.insert(0, newTask);
      await repository.addTask(newTask);
    } catch (e) {
      _errorMessage = "Failed to add task";
    }

    _setLoading(false);
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    final index = _tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) return;

    _tasks[index].isCompleted = !currentStatus;
    notifyListeners();

    try {
      await repository.updateTaskStatus(taskId, !currentStatus);
    } catch (e) {
      _tasks[index].isCompleted = currentStatus; // Rollback
      _errorMessage = "Failed to update task";
      notifyListeners();
    }
  }

Future<void> editTask(String taskId, String newTitle, {Uint8List? newImageBytes, bool removeImage = false}) async {
    final index = _tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final oldTitle = task.title;
    final oldImageUrl = task.imageUrl;

    _setLoading(true);

    try {
      String? finalImageUrl = oldImageUrl;
      String? imageToDeleteFromS3 = (newImageBytes != null || removeImage) ? oldImageUrl : null;

      // 1. Upload new image if provided
      if (newImageBytes != null) {
        finalImageUrl = await (repository as TaskRepositoryImpl)
            .remoteDataSource
            .uploadImageToS3(newImageBytes);
      } else if (removeImage) {
        finalImageUrl = null;
      }

      // 2. Update local state instantly
      task.title = newTitle;
      task.imageUrl = finalImageUrl;
      notifyListeners();

      // 3. Send update to API
      await repository.updateTaskTitleAndImage(
        taskId, 
        newTitle, 
        newImageUrl: newImageBytes != null ? finalImageUrl : null,
        removeImage: removeImage,
        oldImageUrl: imageToDeleteFromS3,
      );

    } catch (e) {
      // Rollback on failure
      task.title = oldTitle;
      task.imageUrl = oldImageUrl;
      _errorMessage = "Failed to update task";
      notifyListeners();
    }
    _setLoading(false);
  }

Future<void> deleteTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) return;
    
    final task = _tasks[taskIndex];
    _tasks.removeAt(taskIndex);
    notifyListeners();

    try {
      // Pass the imageUrl so AWS can delete it from the S3 bucket
      await repository.deleteTask(taskId, imageUrl: task.imageUrl); 
    } catch (e) {
      _tasks.insert(taskIndex, task);
      _errorMessage = "Failed to delete task";
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
