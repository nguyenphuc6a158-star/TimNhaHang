import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/notes/data/models/notes_model.dart';

abstract class NotesRemoteDatasource {
  Future<List<NoteModel>> getAll();
  Future<NoteModel?> getNote(String id);
  Future<void> add(NoteModel note);
  Future<void> update(NoteModel note);
  Future<void> delete(String id);
}
class NotesRemoteDataSourceImpl implements NotesRemoteDatasource {
  final FirebaseRemoteDS<NoteModel> _remoteSource;
  NotesRemoteDataSourceImpl() : _remoteSource = FirebaseRemoteDS<NoteModel>(
    collectionName: 'notes',
    fromFirestore: (doc) => NoteModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );


  @override
  Future<List<NoteModel>> getAll() async {
    List<NoteModel> notes = [];
    notes = await _remoteSource.getAll();
    return notes;
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    NoteModel? notes = await _remoteSource.getById(id);
    return notes;
  }

  @override
  Future<void> add(NoteModel notes) async {
    await _remoteSource.add(notes);
  }

  @override
  Future<void> update(NoteModel notes) async {
    await _remoteSource.update(notes.id.toString(), notes);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
}