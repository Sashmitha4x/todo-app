import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  
  Future<TaskEntity> addTask(TaskEntity task);
  
  Future<void> updateTaskStatus(String taskId, bool isCompleted);
  
  // Upgraded to handle both title changes and image updates/removals
  Future<void> updateTaskTitleAndImage(
    String taskId, 
    String title, {
    String? newImageUrl, 
    bool removeImage = false, 
    String? oldImageUrl,
  });
  
  // Upgraded to accept the imageUrl so it can be deleted from S3
  Future<void> deleteTask(String taskId, {String? imageUrl});
}