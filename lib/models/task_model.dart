// lib/models/task_model.dart
class TaskModel {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime scheduledTime;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.scheduledTime,
  });
}