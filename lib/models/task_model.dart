// lib/models/task_model.dart
class TaskModel {
  final String id;
  final String userId;
  final String title;
  bool isCompleted;
  final DateTime scheduledTime;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    required this.scheduledTime,
  });

  // Convert TaskModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }

  // Create TaskModel from JSON (Firestore document)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : DateTime.now(),
    );
  }
}