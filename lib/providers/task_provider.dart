import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

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

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    final newTask = TaskEntity(
      taskId: const Uuid().v4(),
      title: title.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    // Optimistic UI update
    _tasks.insert(0, newTask);
    notifyListeners();

    try {
      await repository.addTask(newTask);
    } catch (e) {
      _tasks.remove(newTask); // Rollback on failure
      _errorMessage = "Failed to add task";
      notifyListeners();
    }
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

  Future<void> updateTaskTitle(String taskId, String newTitle) async {
    final index = _tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) return;

    final oldTitle = _tasks[index].title;
    _tasks[index].title = newTitle;
    notifyListeners();

    try {
      await repository.updateTaskTitle(taskId, newTitle);
    } catch (e) {
      _tasks[index].title = oldTitle; // Rollback on failure
      _errorMessage = "Failed to update task title";
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    _tasks.removeAt(taskIndex);
    notifyListeners();

    try {
      await repository.deleteTask(taskId);
    } catch (e) {
      _tasks.insert(taskIndex, task); // Rollback
      _errorMessage = "Failed to delete task";
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
