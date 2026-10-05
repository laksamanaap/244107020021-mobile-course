import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/db.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import 'offline_providers.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(openDb: openAppDatabase);
});

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

/// Semua mutasi catatan lewat kelas ini agar notes + dirtyCount ikut di-refresh.
class NoteActions {
  NoteActions(this._ref);

  final Ref _ref;

  NoteRepository get _repo => _ref.read(noteRepositoryProvider);

  void _refresh() {
    _ref.invalidate(notesProvider);
    _ref.invalidate(dirtyCountProvider);
  }

  Future<void> add({required String title, required String content}) async {
    await _repo.insertNote(
      Note(
        title: title,
        content: content,
        dirty: true,
        updatedAt: DateTime.now(),
      ),
    );
    _refresh();
  }

  Future<void> update(Note note) async {
    await _repo.updateNote(note);
    _refresh();
  }

  Future<void> delete(int id) async {
    await _repo.deleteNote(id);
    _refresh();
  }

  Future<void> sync({Duration latency = const Duration(seconds: 1)}) async {
    final offline = _ref.read(forceOfflineProvider);
    await syncNotes(repo: _repo, offline: offline, latency: latency);
    _refresh();
  }
}

final noteActionsProvider = Provider<NoteActions>((ref) {
  return NoteActions(ref);
});
