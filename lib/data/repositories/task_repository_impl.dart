import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../sources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskEntity>> getTasks() async {
    final taskModels = await remoteDataSource.fetchTasks();
    // This explicitly creates a List<TaskEntity> at runtime, preventing the crash!
    return List<TaskEntity>.from(taskModels);
  }

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    final taskModel = TaskModel(
      taskId: task.taskId,
      title: task.title,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
    return await remoteDataSource.createTask(taskModel);
  }

  @override
  Future<void> updateTaskStatus(String taskId, bool isCompleted) =>
      remoteDataSource.updateTask(taskId, isCompleted);

  @override
  Future<void> deleteTask(String taskId) => remoteDataSource.deleteTask(taskId);

  @override
  Future<void> updateTaskTitle(String taskId, String newTitle) =>
      remoteDataSource.updateTaskTitle(taskId, newTitle);
}
