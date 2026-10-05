import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

/// Repository palsu: openDb melempar agar tidak menyentuh SQLite.
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository() : super(openDb: () => throw UnimplementedError());

  final List<Note> notes = [];
  int _nextId = 1;

  @override
  Future<List<Note>> fetchNotes() async {
    final copy = List<Note>.from(notes);
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  @override
  Future<Note?> getById(int id) async {
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertNote(Note note) async {
    final id = _nextId++;
    notes.add(
      note.copyWith(id: id, dirty: true, updatedAt: note.updatedAt),
    );
    return id;
  }

  @override
  Future<int> updateNote(Note note) async {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index < 0) return 0;
    notes[index] = note.copyWith(dirty: true, updatedAt: DateTime.now());
    return 1;
  }

  @override
  Future<int> deleteNote(int id) async {
    final before = notes.length;
    notes.removeWhere((n) => n.id == id);
    return before - notes.length;
  }

  @override
  Future<int> countDirty() async => notes.where((n) => n.dirty).length;

  @override
  Future<List<Note>> fetchDirtyNotes() async =>
      notes.where((n) => n.dirty).toList();

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < notes.length; i++) {
      notes[i] = notes[i].copyWith(dirty: false);
    }
  }
}

void main() {
  test('1. Note toMap/fromMap roundtrip', () {
    final original = Note(
      id: 1,
      title: 'Judul',
      content: 'Isi',
      dirty: true,
      updatedAt: DateTime.parse('2026-03-15T10:00:00.000'),
    );
    final restored = Note.fromMap(original.toMap());
    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.content, original.content);
    expect(restored.dirty, original.dirty);
    expect(restored.updatedAt, original.updatedAt);
  });

  test('2. dirty disimpan sebagai 1/0 di toMap', () {
    final dirty = Note(
      title: 'a',
      content: 'b',
      dirty: true,
      updatedAt: DateTime.now(),
    );
    final clean = Note(
      title: 'a',
      content: 'b',
      dirty: false,
      updatedAt: DateTime.now(),
    );
    expect(dirty.toMap()['dirty'], 1);
    expect(clean.toMap()['dirty'], 0);
    expect(Note.fromMap({...dirty.toMap(), 'dirty': 1}).dirty, isTrue);
    expect(Note.fromMap({...clean.toMap(), 'dirty': 0}).dirty, isFalse);
  });

  test('3. insertNote menandai dirty', () async {
    final repo = FakeNoteRepository();
    await repo.insertNote(
      Note(title: 'Baru', content: 'x', updatedAt: DateTime.now()),
    );
    expect(repo.notes.single.dirty, isTrue);
    expect(await repo.countDirty(), 1);
  });

  test('4. updateNote menandai dirty dan memperbarui updatedAt', () async {
    final repo = FakeNoteRepository();
    final id = await repo.insertNote(
      Note(
        title: 'Lama',
        content: 'x',
        updatedAt: DateTime.parse('2020-01-01T00:00:00.000'),
      ),
    );
    final before = repo.notes.single.updatedAt;
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repo.updateNote(
      Note(
        id: id,
        title: 'Baru',
        content: 'y',
        dirty: false,
        updatedAt: before,
      ),
    );
    final after = repo.notes.single;
    expect(after.dirty, isTrue);
    expect(after.title, 'Baru');
    expect(after.updatedAt.isAfter(before), isTrue);
  });

  test('5. deleteNote menghapus catatan', () async {
    final repo = FakeNoteRepository();
    final id = await repo.insertNote(
      Note(title: 'Hapus', content: '', updatedAt: DateTime.now()),
    );
    expect(await repo.deleteNote(id), 1);
    expect(repo.notes, isEmpty);
  });

  test('6. markAllSynced membersihkan dirty', () async {
    final repo = FakeNoteRepository();
    await repo.insertNote(
      Note(title: 'A', content: '', updatedAt: DateTime.now()),
    );
    await repo.insertNote(
      Note(title: 'B', content: '', updatedAt: DateTime.now()),
    );
    expect(await repo.countDirty(), 2);
    await repo.markAllSynced();
    expect(await repo.countDirty(), 0);
    expect(repo.notes.every((n) => !n.dirty), isTrue);
  });

  test('7. syncNotes + resolveConflict last-write-wins', () async {
    final repo = FakeNoteRepository();
    await repo.insertNote(
      Note(title: 'Dirty', content: '', updatedAt: DateTime.now()),
    );

    expect(
      () => syncNotes(repo: repo, offline: true, latency: Duration.zero),
      throwsA(isA<OfflineException>()),
    );

    await syncNotes(repo: repo, offline: false, latency: Duration.zero);
    expect(await repo.countDirty(), 0);

    final older = Note(
      id: 1,
      title: 'lama',
      content: '',
      updatedAt: DateTime.parse('2024-01-01T00:00:00.000'),
    );
    final newer = Note(
      id: 1,
      title: 'baru',
      content: '',
      updatedAt: DateTime.parse('2025-01-01T00:00:00.000'),
    );
    expect(resolveConflict(older, newer).title, 'baru');
    expect(resolveConflict(newer, older).title, 'baru');
  });
}
