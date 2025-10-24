import 'package:flutter/material.dart';
import 'package:timnhahang/features/notes/data/data/notes_remote_datasource.dart';
import 'package:timnhahang/features/notes/data/repositories/note_repository_impl.dart';
import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/usecase/add_note.dart';
import 'package:timnhahang/features/notes/domain/usecase/delete_note.dart';
import 'package:timnhahang/features/notes/domain/usecase/get_all_note.dart';
import 'package:timnhahang/features/notes/domain/usecase/update_note.dart';
import 'package:timnhahang/features/notes/presentation/pages/note_form_create_update.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  late final _remote = NotesRemoteDataSourceImpl();
  late final _repo = NoteRepositoryImpl(_remote);

  late final _getAllNotes = GetAllNotes(_repo);
  late final _addNote = AddNote(_repo);
  late final _updateNote = UpdateNote(_repo);
  late final _deleteNote = DeleteNote(_repo);
  List<Note> _notes = [];
  
  @override
  void initState() {
    super.initState();
    _initAuth();
  }
  Future<void> _initAuth() async {
    await _loadNotes();
  }
  Future<void> _loadNotes() async {
    final notes = await _getAllNotes();
    setState(() => _notes = notes);
  }
  Future<void> _delete(String id) async {
    await _deleteNote(id);
    await _loadNotes();
  }
  Future<void> _openForm([Note? note]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormPage(
          note: note,
          addUseCase: _addNote,
          updateUseCase: _updateNote,
        ),
      ),
    );
    if (result == true) _loadNotes();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
          },
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('No Note found.'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final p = _notes[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(p.title[0].toUpperCase())),
                  title: Text(p.title),
                  subtitle: Text('Content ${p.content}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(p.id.toString()),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}