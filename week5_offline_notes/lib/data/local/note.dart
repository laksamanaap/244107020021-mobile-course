class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    this.dirty = true,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final bool dirty;
  final DateTime updatedAt;

  Note copyWith({
    int? id,
    String? title,
    String? content,
    bool? dirty,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'dirty': dirty ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      dirty: (map['dirty'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() =>
      'Note(id: $id, title: $title, dirty: $dirty, updatedAt: $updatedAt)';
}
