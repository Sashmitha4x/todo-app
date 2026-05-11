class TaskEntity {
  final String taskId;
  String title;
  bool isCompleted;
  String? imageUrl; // NEW
  final String createdAt;

  TaskEntity({
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.imageUrl, // NEW
    required this.createdAt,
  });
}