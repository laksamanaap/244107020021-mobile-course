import 'package:sqflite/sqflite.dart';

import '../local/note.dart';

/// Pintu CRUD catatan saja. Cache posts ada di [PostRepository];
/// aturan sync ada di `lib/data/sync.dart`.
class NoteRepository {
  NoteRepository({required this.openDb});

  final Future<Database> Function() openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getById(int id) async {
    final db = await openDb();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<int> insertNote(Note note) async {
    final db = await openDb();
    final toInsert = note.copyWith(
      dirty: true,
      updatedAt: note.updatedAt,
    );
    return db.insert('notes', toInsert.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await openDb();
    final updated = note.copyWith(
      dirty: true,
      updatedAt: DateTime.now(),
    );
    return db.update(
      'notes',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await openDb();
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countDirty() async {
    final db = await openDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Note>> fetchDirtyNotes() async {
    final db = await openDb();
    final rows = await db.query(
      'notes',
      where: 'dirty = ?',
      whereArgs: [1],
      orderBy: 'updated_at ASC',
    );
    return rows.map(Note.fromMap).toList();
  }

  /// Menandai semua catatan dirty sebagai sudah tersinkron.
  Future<void> markAllSynced() async {
    final db = await openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = ?', whereArgs: [1]);
  }
}
