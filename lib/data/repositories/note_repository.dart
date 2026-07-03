import '../datasources/firestore_datasource.dart';
import '../models/note_model.dart';

/// Repository for note CRUD + reorder operations, delegating to [FirestoreDatasource].
class NoteRepository {
  final FirestoreDatasource _datasource;

  NoteRepository({FirestoreDatasource? datasource})
      : _datasource = datasource ?? FirestoreDatasource();

  /// Real-time stream of notes for a user, sorted pinned-first then by order.
  Stream<List<NoteModel>> notesStream(String userId) {
    return _datasource.notesStream(userId);
  }

  /// Creates a new note. Returns null on success or an error string.
  Future<String?> createNote(NoteModel note) async {
    try {
      await _datasource.createNote(note);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Updates an existing note. Returns null on success or an error string.
  Future<String?> updateNote(NoteModel note) async {
    try {
      await _datasource.updateNote(note);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Deletes a note by ID. Returns null on success or an error string.
  Future<String?> deleteNote(String noteId) async {
    try {
      await _datasource.deleteNote(noteId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Batch-updates the [order] field for all notes in [notes].
  /// Returns null on success or an error string.
  Future<String?> reorderNotes(List<NoteModel> notes) async {
    try {
      await _datasource.reorderNotes(notes);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
