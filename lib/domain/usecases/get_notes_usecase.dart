import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

/// Use case: Get real-time stream of notes for a user.
class GetNotesUsecase {
  final NoteRepository _repository;

  GetNotesUsecase(this._repository);

  /// Returns a [Stream] of [NoteModel] list for the given [userId].
  Stream<List<NoteModel>> call(String userId) {
    return _repository.notesStream(userId);
  }
}
