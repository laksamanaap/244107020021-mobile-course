import 'repositories/note_repository.dart';
import 'local/note.dart';

class OfflineException implements Exception {
  OfflineException([this.message = 'Perangkat sedang offline']);

  final String message;

  @override
  String toString() => message;
}

/// Mensimulasikan sinkronisasi catatan dirty ke server.
/// [offline] = true menolak sync (demo force offline / mode pesawat).
/// [latency] bisa di-set `Duration.zero` di test.
Future<void> syncNotes({
  required NoteRepository repo,
  required bool offline,
  Duration latency = const Duration(seconds: 1),
}) async {
  if (offline) {
    throw OfflineException('Sinkronisasi ditolak: mode offline aktif');
  }
  await Future<void>.delayed(latency);
  final dirty = await repo.fetchDirtyNotes();
  // Simulasi upload ke server — di modul cukup delay + mark synced.
  // ignore: avoid_print
  print('Mengunggah ${dirty.length} catatan dirty...');
  await repo.markAllSynced();
}

/// Last-write-wins berdasarkan [Note.updatedAt].
Note resolveConflict(Note local, Note remote) {
  if (local.updatedAt.isAfter(remote.updatedAt)) return local;
  return remote;
}
