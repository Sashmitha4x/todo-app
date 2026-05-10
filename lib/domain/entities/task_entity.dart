class TaskEntity {
  final String taskId;
  String title; // <-- Remove 'final' here
  bool isCompleted;
  final String createdAt;

  TaskEntity({
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });
}