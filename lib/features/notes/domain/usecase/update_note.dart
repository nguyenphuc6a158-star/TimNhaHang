
import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/repositories/note_reposiitory.dart';

class UpdateNote{
  final NoteReposiitory repository;

  UpdateNote(this.repository);

  Future<void> call(Note note) async {
    await repository.updateNote(note);
  }

}