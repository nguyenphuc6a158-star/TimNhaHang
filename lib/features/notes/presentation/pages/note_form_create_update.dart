import 'package:flutter/material.dart';
import 'package:timnhahang/features/notes/domain/entities/note.dart';
import 'package:timnhahang/features/notes/domain/usecase/add_note.dart';
import 'package:timnhahang/features/notes/domain/usecase/update_note.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;
  final AddNote addUseCase;
  final UpdateNote updateUseCase;

  const NoteFormPage({
    super.key,
    this.note,
    required this.addUseCase,
    required this.updateUseCase,
  });

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) return; 
    _formKey.currentState!.save();
    final newNote = Note(
      id: widget.note?.id ?? '',
      title: _title,
      content: _content,
    );

    if (widget.note == null) {
      await widget.addUseCase(newNote);
    } else {
      await widget.updateUseCase(newNote);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Note' : 'Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Enter Title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                validator: (v) => v!.isEmpty ? 'Enter Content' : null,
                onSaved: (v) => _content = v!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
