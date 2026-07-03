import '../datasources/firestore_datasource.dart';
import '../models/task_model.dart';

/// Repository for task CRUD operations, delegating to [FirestoreDatasource].
class TaskRepository {
  final FirestoreDatasource _datasource;

  TaskRepository({FirestoreDatasource? datasource})
      : _datasource = datasource ?? FirestoreDatasource();

  /// Real-time stream of tasks for a user.
  Stream<List<TaskModel>> tasksStream(String userId) {
    return _datasource.tasksStream(userId);
  }

  /// Creates a new task. Returns null on success or an error string.
  Future<String?> createTask(TaskModel task) async {
    try {
      await _datasource.createTask(task);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Toggles task completion. Returns null on success or an error string.
  Future<String?> toggleTask(String taskId, bool isCompleted) async {
    try {
      await _datasource.toggleTask(taskId, isCompleted);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Deletes a task by ID. Returns null on success or an error string.
  Future<String?> deleteTask(String taskId) async {
    try {
      await _datasource.deleteTask(taskId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
