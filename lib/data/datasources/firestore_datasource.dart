import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

/// Data source for all Cloud Firestore operations.
class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Collections ──────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection('notes');

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  // ── Notes ─────────────────────────────────────────────────────────────────

  /// Returns a real-time stream of notes for [userId], sorted:
  /// pinned notes first, then by [order] ascending (custom user order).
  /// Limited to 20 documents to control Firestore read costs.
  ///
  /// Requires composite index: userId ASC + isPinned DESC + order ASC.
  /// Deploy via: firebase deploy --only firestore:indexes
  Stream<List<NoteModel>> notesStream(String userId) {
    return _notes
        .where('userId', isEqualTo: userId)
        .orderBy('isPinned', descending: true)
        .orderBy('order')
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NoteModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Creates a new note document. The [NoteModel.id] is ignored;
  /// Firestore generates a new document ID.
  Future<void> createNote(NoteModel note) async {
    try {
      await _notes.add(note.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to create note: ${e.message}');
    }
  }

  /// Updates an existing note document.
  Future<void> updateNote(NoteModel note) async {
    try {
      await _notes.doc(note.id).update(note.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update note: ${e.message}');
    }
  }

  /// Deletes a note document by [noteId].
  Future<void> deleteNote(String noteId) async {
    try {
      await _notes.doc(noteId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete note: ${e.message}');
    }
  }

  /// Batch-updates the [order] field of all notes in [notes] in one
  /// Firestore round-trip, preserving user-defined drag-and-drop order.
  Future<void> reorderNotes(List<NoteModel> notes) async {
    if (notes.isEmpty) return;
    try {
      final batch = _firestore.batch();
      for (final note in notes) {
        batch.update(_notes.doc(note.id), {'order': note.order});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Failed to reorder notes: ${e.message}');
    }
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  /// Returns a real-time stream of tasks for the given [userId].
  Stream<List<TaskModel>> tasksStream(String userId) {
    try {
      return _tasks
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new task document.
  Future<void> createTask(TaskModel task) async {
    try {
      await _tasks.add(task.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to create task: ${e.message}');
    }
  }

  /// Toggles the [isCompleted] field of a task.
  Future<void> toggleTask(String taskId, bool isCompleted) async {
    try {
      await _tasks.doc(taskId).update({'isCompleted': isCompleted});
    } on FirebaseException catch (e) {
      throw Exception('Failed to toggle task: ${e.message}');
    }
  }

  /// Deletes a task document by [taskId].
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasks.doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete task: ${e.message}');
    }
  }
}
