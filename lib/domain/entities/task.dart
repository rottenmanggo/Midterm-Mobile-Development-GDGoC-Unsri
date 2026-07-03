/// Pure Dart task entity — no Firebase imports.
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return Task(
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
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
