

import 'package:timnhahang/features/notes/domain/entities/note.dart';

abstract class NoteReposiitory {
  Future<List<Note>> getNotes();
  Future<Note> getNote(String id);
  Future<void> createNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}