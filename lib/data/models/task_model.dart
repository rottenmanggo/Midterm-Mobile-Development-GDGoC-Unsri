import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a task item in Firestore.
class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final Timestamp createdAt;
  final String userId;

  const TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    Timestamp? createdAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
