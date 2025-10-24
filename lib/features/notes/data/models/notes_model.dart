import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/notes/domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
  };

  factory NoteModel.fromEntity(Note e) => NoteModel(
    id: e.id,
    title: e.title,
    content: e.content,
  );  
}
