

import 'package:timnhahang/features/notes/domain/repositories/note_reposiitory.dart';

class DeleteNote {
  final NoteReposiitory repository;

  DeleteNote(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNote(id);
  }


}