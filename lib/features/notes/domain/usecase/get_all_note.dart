import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/repositories/note_reposiitory.dart';

class GetAllNotes{
  final NoteReposiitory repository;
  GetAllNotes(this.repository);
  Future<List<Note>> call() => repository.getNotes();
}


