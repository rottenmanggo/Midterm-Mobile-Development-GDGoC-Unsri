import '../../data/repositories/note_repository.dart';

/// Use case: Delete a note by ID.
class DeleteNoteUsecase {
  final NoteRepository _repository;

  DeleteNoteUsecase(this._repository);

  /// Executes the deletion. Returns null on success or an error string.
  Future<String?> call(String noteId) {
    return _repository.deleteNote(noteId);
  }
}
