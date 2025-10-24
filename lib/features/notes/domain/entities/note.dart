class Note {
  final String id;
  final String title;
  final String content;

  const Note({
    required this.id,
    required this.title,
    required this.content,
  });
  
  @override
  String toString() {
    return 'Note(id: $id,title: $title, content: $content)';
  }

  copyWith({required String id}) {}
}