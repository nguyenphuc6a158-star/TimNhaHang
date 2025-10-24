

import 'package:timnhahang/features/notes/data/data/notes_remote_datasource.dart';
import 'package:timnhahang/features/notes/data/models/notes_model.dart';
import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/repositories/note_reposiitory.dart';

class NoteRepositoryImpl extends NoteReposiitory {
  final NotesRemoteDatasource remoteDataSource;
  NoteRepositoryImpl(this.remoteDataSource);
  @override
  Future<void> createNote(Note note) async {
    NoteModel noteModel = NoteModel.fromEntity(note);
    await remoteDataSource.add(noteModel);
  }
  @override
  Future<void> deleteNote(String id) async {
    await remoteDataSource.delete(id);
  }

  @override
  Future<Note> getNote(String id) async {
    NoteModel? noteModel = await remoteDataSource.getNote(id);
    if (noteModel == null) {
      throw Exception('Note not found');
    }
    return noteModel;
  }

  @override
  Future<List<Note>> getNotes() async {
    List<NoteModel> noteModels = await remoteDataSource.getAll();
    return noteModels;
  }
  @override
  Future<void> updateNote(Note note) async {
    await remoteDataSource.update(NoteModel.fromEntity(note));

  }
}