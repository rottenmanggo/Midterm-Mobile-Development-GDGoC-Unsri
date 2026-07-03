import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

/// Provider managing tasks state.
class TasksProvider extends ChangeNotifier {
  final TaskRepository _repository;
  final _uuid = const Uuid();

  bool _isLoading = false;
  String? _errorMessage;

  TasksProvider({TaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Real-time stream of tasks for a user.
  Stream<List<TaskModel>> tasksStream(String userId) {
    return _repository.tasksStream(userId);
  }

  /// Creates a new task.
  Future<String?> createTask({
    required String userId,
    required String title,
  }) async {
    _setLoading(true);
    final task = TaskModel(
      id: _uuid.v4(),
      title: title.trim(),
      isCompleted: false,
      createdAt: Timestamp.now(),
      userId: userId,
    );
    final error = await _repository.createTask(task);
    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  /// Toggles task completion.
  Future<String?> toggleTask(String taskId, bool isCompleted) async {
    final error = await _repository.toggleTask(taskId, isCompleted);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  /// Deletes a task.
  Future<String?> deleteTask(String taskId) async {
    final error = await _repository.deleteTask(taskId);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
