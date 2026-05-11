import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.taskId,
    required super.title,
    super.isCompleted,
    super.imageUrl,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskId'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      imageUrl: json['imageUrl'], 
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted,
      'imageUrl': imageUrl, 
      'createdAt': createdAt,
    };
  }
}