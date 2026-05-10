import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  Future<TaskEntity> addTask(TaskEntity task);
  Future<void> updateTaskStatus(String taskId, bool isCompleted);
  Future<void> deleteTask(String taskId);
  Future<void> updateTaskTitle(String taskId, String newTitle);
}