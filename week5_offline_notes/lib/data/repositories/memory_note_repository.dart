import '../local/note.dart';
import 'note_repository.dart';

/// Penyimpanan catatan di memori — dipakai di Flutter Web (sqflite tidak support).
class MemoryNoteRepository extends NoteRepository {
  MemoryNoteRepository({bool seedDemo = false})
      : super(openDb: () => throw UnimplementedError('web')) {
    if (seedDemo) {
      final now = DateTime.now();
      _notes.addAll([
        Note(
          id: _nextId++,
          title: 'Catatan Kuliah Mobile',
          content: 'Belajar SharedPreferences, SQLite, dan offline-first sync.',
          dirty: true,
          updatedAt: now,
        ),
        Note(
          id: _nextId++,
          title: 'Todo Praktikum 5',
          content: 'Jalankan flutter test dan isi tabel uji manual.',
          dirty: true,
          updatedAt: now.subtract(const Duration(minutes: 5)),
        ),
      ]);
    }
  }

  final List<Note> _notes = [];
  int _nextId = 1;

  @override
  Future<List<Note>> fetchNotes() async {
    final copy = List<Note>.from(_notes);
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  @override
  Future<Note?> getById(int id) async {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertNote(Note note) async {
    final id = _nextId++;
    _notes.add(note.copyWith(id: id, dirty: true));
    return id;
  }

  @override
  Future<int> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index < 0) return 0;
    _notes[index] = note.copyWith(dirty: true, updatedAt: DateTime.now());
    return 1;
  }

  @override
  Future<int> deleteNote(int id) async {
    final before = _notes.length;
    _notes.removeWhere((n) => n.id == id);
    return before - _notes.length;
  }

  @override
  Future<int> countDirty() async => _notes.where((n) => n.dirty).length;

  @override
  Future<List<Note>> fetchDirtyNotes() async =>
      _notes.where((n) => n.dirty).toList();

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < _notes.length; i++) {
      _notes[i] = _notes[i].copyWith(dirty: false);
    }
  }
}
