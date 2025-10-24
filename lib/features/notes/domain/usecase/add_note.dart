import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/repositories/note_reposiitory.dart';

class AddNote{
  final NoteReposiitory repository;
  AddNote(this.repository);
  Future<void> call(Note note) => repository.createNote(note);
}


