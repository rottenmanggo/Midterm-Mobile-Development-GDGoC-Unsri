import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';

/// Provider managing notes state for the current user.
class NotesProvider extends ChangeNotifier {
  final NoteRepository _repository;
  final CreateNoteUsecase _createUsecase;
  final GetNotesUsecase _getUsecase;
  final DeleteNoteUsecase _deleteUsecase;
  final _uuid = const Uuid();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotesProvider({NoteRepository? repository})
      : _repository = repository ?? NoteRepository(),
        _createUsecase = CreateNoteUsecase(repository ?? NoteRepository()),
        _getUsecase = GetNotesUsecase(repository ?? NoteRepository()),
        _deleteUsecase = DeleteNoteUsecase(repository ?? NoteRepository());

  // ── Getters ──────────────────────────────────────────────────────────────

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns a stream of notes for the given [userId].
  /// Call this once and store the stream — do NOT call on every rebuild.
  Stream<List<NoteModel>> notesStream(String userId) {
    return _getUsecase(userId);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Updates the cached notes list from stream.
  void updateNotes(List<NoteModel> notes) {
    _notes = notes;
    _errorMessage = null;
    notifyListeners();
  }

  /// Creates a new note for the given [userId].
  /// New notes start at order=0 (top of their pinned/unpinned group).
  Future<String?> createNote({
    required String userId,
    required String title,
    required String content,
    required String category,
    required String cardColor,
    required String cardType,
    required bool isPinned,
  }) async {
    _setLoading(true);
    final note = NoteModel(
      id: _uuid.v4(),
      title: title.trim(),
      content: content.trim(),
      category: category,
      cardColor: cardColor,
      cardType: cardType,
      isPinned: isPinned,
      order: 0,
      createdAt: Timestamp.now(),
      userId: userId,
    );
    final error = await _createUsecase(note);
    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  /// Updates an existing note.
  Future<String?> updateNote(NoteModel note) async {
    _setLoading(true);
    final error = await _repository.updateNote(note);
    _setLoading(false);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  /// Deletes a note by ID.
  Future<String?> deleteNote(String noteId) async {
    final error = await _deleteUsecase(noteId);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
    return error;
  }

  /// Batch-updates the [order] field for the reordered note list.
  /// Optimistic UI is handled by [BentoGrid] — this only syncs to Firestore.
  Future<void> reorderNotes(List<NoteModel> reorderedNotes) async {
    final error = await _repository.reorderNotes(reorderedNotes);
    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clears all notes (called on logout).
  void clearNotes() {
    _notes = [];
    _errorMessage = null;
    notifyListeners();
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
