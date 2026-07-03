import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

/// Use case: Create a new note.
class CreateNoteUsecase {
  final NoteRepository _repository;

  CreateNoteUsecase(this._repository);

  /// Executes the use case. Returns null on success or an error string.
  Future<String?> call(NoteModel note) {
    return _repository.createNote(note);
  }
}
